require File.dirname(__FILE__) + '/../../spec_helper'

describe Task::Task do
  before do
    @task = Task::Task.new
  end

  describe "completed status" do
    it "knows what completed? means" do
      @task.completed = true
      @task.should be_completed
    end
      
  end

  describe "due date" do
    it "has a due date" do
      @task.due_at = 1.day.ago
      @task.should be_past_due
    end
  end

  describe "completed date" do
    it "accepts completion dates" do
      @task.completed_at =  Time.now
      @task.should be_completed
    end
  end

  describe "past due" do
    it "does not describe completed items as past due" do
      @task.due_at = 1.day.ago
      @task.completed_at = Time.now
      @task.should_not be_past_due
    end

    it "does not mark things as past due until the next day" do
      @task.due_at = Time.now
      @task.should_not be_past_due
    end

    it "does mark things as past due the next day" do
      @task.due_at = 1.day.ago
      @task.should be_past_due
    end
  end



end
