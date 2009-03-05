#!/usr/bin/env ruby

require "open3"
require 'pp'
require 'rubygems'

module CIGDiff
class TestAnalyzer
  # returns a results hash that can be used with print_results and print_results_comparison
  # methods
  def run_tests(label, cmd = "rake test:everything RCOV_NO_HTML=true")

    puts "running tests for " + label + " ... "
    text, error = capture_output(label, cmd)
    puts "#{label} tests completed"

    results = analyze_output(text)

    results[:label] = label
    results[:error_text] = error
    return results
  end

  def print_results(results)
    puts "results for #{results[:label]}:"
    if !results[:completed]
      puts "[TEST COMMAND FAILED]"
      puts results[:full_text]
      puts results[:error_text]
      return
    end

    puts "Bad tests: " + bad_test_totals(results)
    puts
    print_failures_list(results[:failed_items])
    puts

    if results[:stats]
      puts "Coverage: %2.1f%%" % results[:stats][:coverage]
    end
  end

  def print_results_comparison(results_from, results_to)
    label_from, label_to = results_from[:label], results_to[:label]
    puts "\n=============================="
    puts "Comparing #{label_from} to #{label_to}:"

    if !results_from[:completed]
      puts "[TEST COMMAND FAILED]"
      puts results_from[:full_text]
      puts results_from[:error_text]

      return
    end
    if !results_to[:completed]
      puts "[TEST COMMAND FAILED]"
      puts results_to[:full_text]
      puts results_to[:error_text]

      return
    end

    puts "=============================="
    puts "* Test Failures Summary:"
    print_columns "  #{label_from}", bad_test_totals(results_from)
    print_columns "  #{label_to}", bad_test_totals(results_to)

    fixed, broken = sort_out_broken_tests(results_from, results_to)
    puts
    if fixed.empty? and broken.empty?
      puts "  test status not changed"
    else
      fixed.each do |item|
        puts "  + fixed " + test_info(item)
      end
      broken.each do |item|
        puts "  - broke " + test_info(item)
      end
    end
    puts
    if results_from[:stats] and results_to[:stats]
      puts "* Coverage:"
      print_columns "  #{label_from}", ("%2.1f%%" % results_from[:stats][:coverage])
      print_columns "  #{label_to}", ("%2.1f%%" % results_to[:stats][:coverage])
    end
    puts
    puts "* Analysis: " + get_comparison_analysis(results_from, results_to, fixed, broken)
    puts "=============================="
    puts
  end
%{

Comparing master~2 to master~1:
Bad tests:
  master~3 - 20 (6 failed assertions)
  master~1 - 10 (4 failed assertions)

fixed ActivityTest#blah
fixed ...
fixed ...
broke ...
broke ...

Coverage:
  master~3 - 20.0%
  master~1 - 20.2%

Analysis:
}
  private
  def print_columns(col1, col2, col1_width = 30)
    col1_padding = col1_width - col1.length
    col1_padding = 0 if col1_padding < 0

    puts col1 + (" " * col1_padding) + " " + col2
  end

  def bad_test_totals(results)
    total_bad = results[:totals][:failures] + results[:totals][:errors]
    "%d  (%d failed assertions) (%d errors)" % [total_bad, results[:totals][:failures], results[:totals][:errors]]
  end

  def print_failures_list(items)
    items.each do |item|
      puts test_info(item)
    end
  end

  def test_info(item)
    item[:class] + "#" + item[:method] + "  (#{item[:failure_type]})"
  end

  def get_comparison_analysis(results_from, results_to, fixed_items, broken_items)
    # BAD if new tests failing and coverage not increased
    # GOOD if coverage increased (no matter what else)
    # GOOD if tests fixed and coverage the same
    # OK if coverage the same and tests the same

    unless results_from[:stats] and results_to[:stats]
      # no coverage at all
      # bad if any tests are broken
      # good if tests are fixed
      return "BAD" unless broken_items.empty?
      return "GOOD" unless fixed_items.empty?
      return "OK"
    end

    cov_delta = results_to[:stats][:coverage] - results_from[:stats][:coverage]

    if !broken_items.empty? and cov_delta <= 0
      # broke new items without new coverage
      "BAD - tests broken (without improving coverage)"
    elsif cov_delta > 0
      # increasing coverage is always good
      "GOOD - increased coverage"
    elsif !fixed_items.empty? and cov_delta == 0
      "GOOD - fixed tests"
    elsif cov_delta < 0
      "BAD - coverage decreased"
    else
      "OK"
    end
  end

  def sort_out_broken_tests(results_from, results_to)
    items_from = results_from[:failed_items]
    items_to = results_to[:failed_items]

    fixed, broken = [], []
    # fixed items are ones in from_items list, but not in to_items list
    items_from.each do |from_item|
      fixed << from_item unless items_to.detect {|to_item| to_item[:method] == from_item[:method] && to_item[:class] == from_item[:class]}
    end

    # broken items are from items_to that were not in items_from
    items_to.each do |to_item|
      broken << to_item unless items_from.detect {|from_item| to_item[:method] == from_item[:method] && to_item[:class] == from_item[:class]}
    end

    return fixed, broken
  end

  def capture_output(label, cmd)
    stdin, stdout, stderr = Open3.popen3(cmd)
    out = stdout.read
    err = stderr.read
# require 'ruby-debug';debugger

    return out, err
  end

  def analyze_output(text)
    results = {:completed => true, :full_text => text}
    text =~ /Finished in (\d+\.\d+) seconds\.$(.*?)((\d+) tests, (\d+) assertions, (\d+) failures, (\d+) errors)/m

    unless $~
      results[:completed] = false
      return results
    end

    results[:time] = $~[1].to_f
    results[:failed_items] = analyze_failed_tests_section($~[2])

    results[:totals] = {
      :text => $~[3],
      :tests => $~[4].to_i,
      :assertions => $~[5].to_i,
      :failures => $~[6].to_i,
      :errors => $~[7].to_i,
    }

    # handle the rcov stats if we have them
    text =~ /(\d+\.\d+)%\s+(\d+) file\(s\)\s+(\d+) Lines\s+(\d+) LOC/
    if $~
      results[:stats] = {
        :text => $~[0],
        :coverage => $~[1].to_f,
        :files => $~[2].to_i,
        :lines => $~[3].to_i,
        :lines_of_code => $~[4].to_i
      }
    end

    return results
  end

  def analyze_failed_tests_section(text)
    sections = text.split(/(\d+\).*?Error|Failure)/)
    header, failure_type = body = nil
    results = []
    sections.each do |s|
      if s =~ /(Error|Failure)$/
        header = s
        failure_type = $~[1]
      elsif s =~ /(test_\w+?)\((\w+?Test)\)/
        body = s
        test_method = $~[1]
        test_class = $~[2]

        result = {
          :text => (header + body),
          :failure_type => failure_type,
          :class => test_class,
          :method => test_method
        }

        results << result
      end
    end

    return results
  end
end

class Git
  def stash_work
    return if no_changes?
    puts "git: Stashing your working tree and index. If this fails you can restore your work with 'git stash pop --index'"
    %x{git stash save '__CIG_DIFF__ stash'}
    @stashed = true
  end

  def unstash_work
    return unless @stashed
    puts "git: Unstashing your working tree and index"
    %x{git stash pop --index} unless %x{git stash list}.empty?
  end

  def checkout(ref, label = "")
    puts "git: Checking out #{label} - #{ref}"
    stdin, stdout, stderr = Open3.popen3("git checkout " + ref)
    # %x[git checkout #{ref}]
    out = stdout.read
  end

  def current_branch
    branch = %x{git branch}.split("\n").grep(/^\*\s(.*)/).first.sub("* ", '')
    branch = nil if (branch !~ /\w+/)

    return branch
  end

  def rev_parse(label)
    rev = %x[git rev-parse #{label}].chomp
    rev = nil unless rev =~ /^[\da-z]{40}$/

    return rev
  end

  def warn_about_untracked
    status = %x[git status]
    if status =~ /Untracked files/
      puts "git: WARNING - you have untracked files. These can't be stashed away and will present when older code is checked out. See 'git status'."
    end
  end

  def no_changes?
    return %x[git diff].empty? && %x[git diff --cached].empty?
  end
end

class Driver
  def initialize
    @git = Git.new
    @analyzer = TestAnalyzer.new

    @starting_branch = @git.current_branch

    if @starting_branch !~ /.+/
      puts "No regular brach was checked out"
      exit
    end
  end

  def compare_commit_with_current_work(label)
    if @git.no_changes?
      puts "git: No changes in working tree or index."
      return
    end

    @git.warn_about_untracked
    rev = @git.rev_parse(label)
    if rev.nil?
      puts "git rev-parse can't resolve `#{label}`"
      return
    end

    label_from = label
    label_to = "working tree"

    results_to = @analyzer.run_tests(label_to)
    # be ready to unstash when the program exits
    handle_exit
    @git.stash_work

    @git.checkout rev
    results_from = @analyzer.run_tests(label_from)

    @analyzer.print_results_comparison(results_from, results_to)
  end

  def compare_two_commits(label1, label2)
    @git.warn_about_untracked
    rev1 = @git.rev_parse(label1)
    rev2 = @git.rev_parse(label2)

    if rev1.nil?
      puts "git rev-parse can't resolve `#{label1}`"
      return
    end

    if rev2.nil?
      puts "git rev-parse can't resolve `#{label2}`"
      return
    end

    # compare ref1 and ref2
    label_from = label1
    label_to = label2

    handle_exit
    @git.stash_work

    @git.checkout rev1
    results_from = @analyzer.run_tests(label_from)

    @git.checkout rev2
    results_to = @analyzer.run_tests(label_to)

    @analyzer.print_results_comparison(results_from, results_to)
  end

  def stats_for_work
    if @git.no_changes?
      puts "git: No changes in working tree or index."
      return
    end
    label = "working tree"
    results = @analyzer.run_tests(label)
    @analyzer.print_results(results)
  end

  def stats_for_commit(label)
    @git.warn_about_untracked
    rev = @git.rev_parse(label)
    if rev.nil?
      puts "git rev-parse can't resolve `#{label}`"
      return
    end

    handle_exit
    @git.stash_work
    @git.checkout rev

    results = @analyzer.run_tests(label)
    @analyzer.print_results(results)
  end

  def handle_exit
    Kernel.at_exit {
      puts "exiting"
      @git.checkout @starting_branch
      @git.unstash_work
    }
  end
end


class Main
  def self.run
    if ARGV[0] == "-s"
      # stats for a single commit
      if ARGV[1].nil?
        Driver.new.stats_for_work
      else
        Driver.new.stats_for_commit(ARGV[1])
      end
    elsif ARGV[0] == "-h"
      puts usage
    else
      # compare two things
      if ARGV[0] and ARGV[1]
        # two commits
        Driver.new.compare_two_commits(ARGV[0], ARGV[1])
      elsif ARGV[0]
        Driver.new.compare_commit_with_current_work(ARGV[0])
      else
        Driver.new.compare_commit_with_current_work("HEAD")
      end
    end

  end

  def self.usage
    %Q{
  Usage: cig_diff.rb [-s] [commit1] [commit2]

  Compares test results and (optional) code coverage for 2 commits
  or for a commit and a working tree.

  -s        --  prints stats for a single commit
  commit1   --  first commit to analyze (default HEAD)
  commit2   --  second commit to analyze (working tree is used if not given)
    }
  end
end

end


CIGDiff::Main.run