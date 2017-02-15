$(document).ready(function(){

  let copyButton = document.getElementById('d_clip_button')
  let clip = new Clipboard(copyButton)
  console.log(clip)

  $('#d_clip_button').tooltip({
    trigger: 'click',
    placement: 'bottom'
  })

  function setTooltip(btn, message) {
    $(btn).tooltip('hide')
      .attr('data-original-title', message)
      .tooltip('show')
  }

  function hideTooltip(btn) {
    setTimeout(function() {
      $(btn).tooltip('hide')
    }, 1000)
  }

  clip.on('success', function(e) {
    setTooltip(e.trigger, 'Copied!')
    hideTooltip(e.trigger)
  })

  clip.on('error', function(e) {
    setTooltip(e.trigger, 'Failed!')
    hideTooltip(e.trigger)
  })
})
