$.ready(function () {
  function addFigure() {
    console.log('addFigure');
    $("#advanced-figure-search").append('<input type="text" name="q[]">');
  }

  $("#advanced-figure-search").ready(addFigure);
  $("#advanced-figure-search-add-figure").click(addFigure);
});

