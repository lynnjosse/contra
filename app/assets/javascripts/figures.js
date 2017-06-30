$(document).ready(function () {
  
  function addNode(e) {
    var parentNodeName = $(e.target).closest('.node').children('.center').attr('name');
    var direction = $(e.target).hasClass('left') ? 'left' : 'right';
    // assumes the name starts with a single letter before the bracket:
    var babyNodeName = parentNodeName[0]+'['+direction+']' + parentNodeName.slice(1);
    var replacement = $('\
      <div class="node">\
        <button class="left" type="button">Left</button>\
        <input class="center" type="text" name="'+babyNodeName+'">\
        <button class="right" type="button">Right</button>\
      </div>');
    replacement.children('.left').click(addNode);
    replacement.children('.right').click(addNode);
    $(e.target).replaceWith(replacement);
  }

  $('.left').click(addNode);
  $('.right').click(addNode);
});

