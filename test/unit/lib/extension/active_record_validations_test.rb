require File.dirname(__FILE__) + '/../../../test_helper'

class Page < ActiveRecord::Base
  validates_presence_of_optional_attributes
end

class Extension::ActiveRecordValidationsTest < Test::Unit::TestCase

  def test_defines_optional_attributes_accessor
    assert_nothing_raised do
      Page.new.optional_validation_attributes
      Page.new.optional_validation_attributes = [:summary]
    end

    page = Page.new

    assert_nil page.optional_validation_attributes
    page.optional_validation_attributes = [:summary]
    assert_equal [:summary], page.optional_validation_attributes
  end

  def test_valid_respects_optional_attributes
    page = Page.new(:title => "somepage")

    assert page.valid?

    page.optional_validation_attributes = [:summary]
    assert !page.valid?

    page.optional_validation_attributes = nil
    assert page.valid?
  end

  def test_validation_generates_error_message_on_save
    page = Page.new(:title => "somepage")
    page.optional_validation_attributes = [:summary]

    assert_nothing_raised do
      begin
        page.save!
      rescue ActiveRecord::RecordInvalid => exc
        assert exc.message =~ /Summary is required/
      end
    end
  end

  def test_generated_validation_method
    # see the ? mark at the end
    page = Page.new(:title => "somepage")
    page.optional_validation_attributes = [:summary]

    assert !page.has_optional_validation_attributes?
    page.summary = "hi"
    assert page.has_optional_validation_attributes?
  end
end