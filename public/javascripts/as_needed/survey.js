function surveyDesignerAssignNewQuestionId() {
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

function surveyDesignerUpdatePositions() {
  var i = 0;

  $$('#questions .question .qposition').each(
    function(f) {
      f.value = (i+=1);
    });
}


function surveyDesignerMakeQuestionsSortable() {
  Sortable.create("questions", {
    'elements': $$("#questions .question"),
    'handles': $$("questions .drag_to_move"),
    'onUpdate': surveyDesignerUpdatePositions,
    'tag': 'div' });
}


function surveyDesignerEnableSorting()
{
  surveyDesignerUpdatePositions();
  surveyDesignerAssignNewQuestionId();
  surveyDesignerMakeQuestionsSortable();
}