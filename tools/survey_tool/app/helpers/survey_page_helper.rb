module SurveyPageHelper
  include AssetPageHelper

  def add_questions_links
    links = []
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
      page.insert_html(:bottom, :questions, :partial => 'edit_question', :locals => {:question => object})
      page.call 'surveyDesignerEnableSorting'
    end
  end

  def delete_question_function(question)
    link_to_function(I18n.t(:delete), :class => "delete_question") do |page|
      page.call "$(this).up('.question').remove"
      unless question.new_record?
        page.insert_html :bottom, :questions, "<input type='hidden' name='survey[new_questions_attributes][#{question.id}][deleted]' value='true'>"
      end
    end
  end

  def private_question_checkbox(form)
   content_tag :label, form.check_box(:private) + " " + I18n.t(:private_question_label)
  end

  def their_answer_goes_here
    I18n.t(:their_answer_goes_here_label)
  end

  def respond_to_question_form(response_form, question)
    answer = response_form.object.find_or_build_answer_for_question(question)
    render :partial => 'survey_page/response_form/' + question.partial,
              :locals => {:question => question, :response_form => response_form, :answer => answer}
  end

  def show_answers_for_question(response, question)
    # filter answers for this response and ignore unchecked checkboxes
    answers = @response.answers.select {|a| a.question == question && a.value != SurveyAnswer::CHOICE_FOR_UNCHECKED }

    tags = answers.collect do |answer|
      if answer.asset
        render_asset(answer.asset, answer.value)
      else
        content_tag(:div, answer.display_value, :class => 'answer')
      end
    end

    tags.join("\n")
  end

  def render_asset(asset, name)
    if asset.embedding_partial.any?
      render :partial => asset.embedding_partial
    else
      thumbnail = asset.thumbnails(:large)
      if thumbnail.nil?
        link_to(image_tag(asset.big_icon, :alt => name), asset.url )
      else
        link_to_asset(asset, :large, :class => '')
      end
    end
  end

  # takes a generated +html+ like '<textarea cols="72" id="tid_42" name="text[42]" rows="6">Data</textarea>'
  # and an +instance+ object which is a TagInstance
  # returns modified+ html+ with error markup
  def wrap_error_html(html, instance)
    if html =~ /(input|textarea|select)/ and html !~ /hidden/
      content_tag(:span, html, :class => 'fieldWithErrors')
    else
      html
    end
  end

  def js_next_response_options(rating)
    # rating of 0 has special meaning: it creates a rating of nil, which is
    # skipped in the rating calculation. These nil rating records help us keep
    # track of the fact that the user decided to skip the current response.
    { :url => page_url(@page, :action => 'response-rate', :id => @response.id, :rating => (rating||0)),
      :loading => show_spinner('next_response'),
      :complete => hide_spinner('next_response')
    }
  end

  def js_next_response(rating)
    remote_function(js_next_response_options(rating))
  end
end
