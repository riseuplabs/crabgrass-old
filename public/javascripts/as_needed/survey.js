function survey_designer_assign_new_question_id() {
  var index = 0;
  $$('.question').each(function(question) {
    question.id = "question_" + index;
    index++;
    if(question.innerHTML.include("new_NOID")) {
      var rand = Math.random();      
      question.innerHTML = question.innerHTML.gsub("new_NOID", "new_" + rand);
    }
  });
}

function survey_designer_update_positions() {
  var i = 0;

  $$('#questions .question .qposition').each(
    function(f) {
      f.value = (i+=1); 
    });
}


function survey_designer_make_questions_sortable() {
  Sortable.create("questions", {
    'elements': $$("#questions .question"),
    'handles': $$("questions .drag_to_move"),
    'onUpdate': survey_designer_update_positions,
    'tag': 'div' });
}


function survey_designer_enable_sorting()
{
  survey_designer_update_positions();
  survey_designer_assign_new_question_id();
  survey_designer_make_questions_sortable();
}