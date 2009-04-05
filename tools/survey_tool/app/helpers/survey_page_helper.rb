module SurveyPageHelper
  def add_questions_links
    links = []
    links
    links << add_question_function(:short_text)
    links << add_question_function(:long_text)
    links << add_question_function(:select_one)
    links << add_question_function(:select_many)
    links << add_question_function(:image_upload)
    links << add_question_function(:video_link)

    link_span(*links)
  end

  def add_question_function(question_type)
    # a weird problem with rails where other models in survey_question.rb won't be
    # loaded until SurveyQuestion is mentioned
    SurveyQuestion
    object = "#{question_type}_question".camelize.constantize.new
    object.choices = ["Answer choice 1", "Answer choice 2", "Answer choice 3"]

    link_to_function object.add_question_link_text do |page|
      page.insert_html :bottom, :questions,
                        :partial => 'question', :object => object

      make_questions_sortable(page)

      # "Sortable.create('questions', {elements:$$('#questions .question'), handles:$$('questions .drag_to_move') });"
    end
  end

  def delete_question_function
    link_to_function("delete", :class => "delete_question") do |page|
      page.call "$(this).up('.question').remove"
      make_questions_sortable(page)
    end
  end

  def make_questions_sortable(page)
    page.call "Sortable.create", :questions, {:elements => page.literal('$$("#questions .question")')}
  end

  def their_answer_goes_here
    "Their answer goes here..."[:their_answer_goes_here]
  end
  
  def respond_to_question_form(response_form, question)
    # require 'ruby-debug';debugger
    case question
      when ShortTextQuestion
        response_form.fields_for :answers_attributes, TextAnswer.new, :index => question.id do |f|
          f.text_field :value, :size => 83
        end
      when LongTextQuestion
        response_form.fields_for :answers_attributes, TextAnswer.new, :index => question.id do |f|
          f.text_area :value, :size => "72x6"
        end
      when SelectOneQuestion
        response_form.fields_for :answers_attributes, TextAnswer.new, :index => question.id do |f|
          f.text_area :value, :size => "72x6"
        end
    end
  end

  # def add_answer_choice_button(form)
  #   button_to_function "Add Answer Choice" do |page|
  #     page.insert_html :bottom, page.literal("$(this).up('.fields')"), "z"
  #   end
  # end
end