# LOGO_FACTOR = 1484 / 500 # Ratio of width to height
# LOGO_MARGIN = 40 # Static pixel margins around the logo
# PAGE_FACTOR = .8 # How much of the page the logo takes up

SIZE_CUTOFF = 640

# Relative position of the left side of the arrow relative to the logo's left.
# A_LEFT = 0.7820
# A_LEFT = 0.7820
# Relative position of the bottom of the arrow relative to the logo's bottom.
# A_BOTTOM = 0.870252
# A_BOTTOM = 0.65
A_BOTTOM = 0.74
# Relative width of the arrow relative to the logo's width
A_WIDTH = 0.048
# A_WIDTH = 0.048
CONTENT_H = 0
nav_opacity = {} # Keeps track of nav opacity for hover

# Adjusts the Cirriculum bars. Fired on scroll

# Sets the logo size and position and blank padding space above the logo
window.adjustLogo = ->
  $logo = $("#logo")

  if $(window).width() < SIZE_CUTOFF
    # $("#call_to_action").hide()
    $logo.attr("src", "img/BSS_Logo_256x761.png")
  else
    # $("#call_to_action").show()
    $logo.attr("src", "img/BSS_Logo_500x1484_noarrow.png")

  # w = $(window).width()
  # logo_w = w * PAGE_FACTOR
  # logo_h = w * PAGE_FACTOR / LOGO_FACTOR

  # Needed important flags for svg resizing
  # $logo.css
  #   width: "#{logo_w}px !important"
  #   height: "#{logo_h}px !important"
  # $logo.attr 'width', "#{logo_w}px !important"
  # $logo.attr 'height', "#{logo_h}px !important"

  # $logo_svg = $($logo[0].contentDocument).find("svg")
  # if $logo_svg.length
  #   $logo_svg.attr "width", "#{logo_w}px"
  #   $logo_svg.attr "height", "#{logo_h}px"
  #   $logo_svg.attr "viewBox", "0 0 #{logo_w} #{logo_h}"
  #   $logo_svg.attr "enable-background", "new 0 0 #{logo_w} #{logo_h}"
  #   $logo_svg.css
  #     width: "#{logo_w}px !important"
  #     height: "#{logo_h}px !important"

  # # Setting padding so no content accidentally flows over the logo.
  # $("#page").css
  #   "padding-bottom": logo_h + LOGO_MARGIN

  # $logo.hide()
  # $logo.show()

  # Calculate how much empty space we should generate above the logo to ensure
  # a clean landing page.
  # stack = logo_h + LOGO_MARGIN + $("#hero").outerHeight()
  m = $(window).height() - $("#hero").height()
  m = Math.max(m, 80)
  $("#hero").css
    "margin-top":"#{m}px"

  # Adjust the arrow too.
  adjustArrow()

# Sizes the arrow proporationally to the logo and positions it properly
adjustArrow = () ->
  # logo_w = $("#logo").outerWidth(true)
  logo_h = $("#logo").outerHeight(true)

  $arrow = $("#arrow")
  $head = $("#arrow_head")
  $body = $("#arrow_body")

  $arrow.show()
  # if $(window).width() < SIZE_CUTOFF
  #   A_LEFT = 1
  #   $arrow.css "visibility", "hidden"
  # else
  #   A_LEFT = 0.7820
  #   $arrow.css "visibility", "visible"

  arrow_w = $("#logo").outerWidth() * A_WIDTH
  # arrow_l = logo_w * A_LEFT - arrow_w / 2
  arrow_b = logo_h * A_BOTTOM
  $head.css
    "border-right":"#{arrow_w}px solid transparent"
    "border-left":"#{arrow_w}px solid transparent"
    "border-bottom":"#{arrow_w}px solid #3ba4db"
  $body.css
    "width":"#{arrow_w}px"
    "margin-left":"#{arrow_w/2}px"
  $("#arrow_track").css
    "height":"#{CONTENT_H}px"
    "width":"#{arrow_w}px"
    "margin-left":"-#{(arrow_w+2)/2}px"

  # $arrow.css "left", arrow_l
  $arrow.css "bottom", arrow_b

  arrowHeight()

  # page_w = $body.offset().left + arrow_w + 30
  # $("#page").width page_w

onResize = ->
  CONTENT_H = $(document).height() - $("#hero").outerHeight(true)
  adjustLogo()
  fixCurriculum()
  headers('fix_width')
  setupElements()
  adjustLogo() # Re-setup now that elements have been setup

show_scroll = 0
instructions_shown = false
instruction_show_time = null
onScroll = ->

  if show_scroll == 10
    $("#scroll_up").fadeOut('slow')

  if not instructions_shown
    if $(window).scrollTop() < $("#instruction_header").offset().top + 5
      instruction_show_time = new Date().getTime()
      $("#instruction_header").trigger("click")
      instructions_shown = true

  arrowHeight()
  fixCurriculum()
  headers()

  show_scroll += 1

headers = (fix_width=false)->
  section_headers = $(".section_header")
  scroll_top = $(window).scrollTop()
  h = section_headers.outerHeight()

  # Fade out the 'Apply now' button if we're close to the apply section
  d_apply = Math.min(Math.abs(scroll_top - $("#apply").offset().top), 1500)
  opacity = Math.max(1/750 * d_apply - 1, 0)
  $("#call_to_action").css
    opacity:opacity

  if fix_width is true or fix_width is 'fix_width'
    section_headers.width $("#page").width() - 100

  # Determine which are currently fixed and how high the stack is.
  nav_h = 0
  nav_bot_h = 0
  for header in section_headers
    if $(header).hasClass('fixed_top') then nav_h += h
    else if $(header).hasClass('fixed_bot') then nav_bot_h += h

  win_h = $(window).height()
  for header in section_headers
    $section = $("##{$(header).data("section")}")
    section_top = $section.offset().top
    $header = $(header)
    num_sections = $(".section_header").length - 1

    if $header.hasClass('fixed_top')
      if scroll_top + nav_h > section_top
        null
      else
        $header.css 'position', 'absolute'
        $header.removeClass 'fixed_bot'
        $header.removeClass 'fixed_top'
        $header.css('top', section_top - h)
    else if $header.hasClass('fixed_bot')
      if scroll_top + win_h - nav_bot_h + h < section_top
        null
      else
        $header.css 'position', 'absolute'
        $header.removeClass 'fixed_bot'
        $header.removeClass 'fixed_top'
        $header.css('top', section_top - h)
    else
      # The header is positioned absolutely, determine which fixed mode it should be in given the position on the page
      if scroll_top + nav_h > section_top - h
        $header.css 'position', 'fixed'
        $header.css('bottom', 'auto')
        $header.css('top', h * $(header).data("order"))
        $header.removeClass 'fixed_bot'
        $header.addClass 'fixed_top'
      else if $header.offset().top + h + nav_bot_h > scroll_top + win_h
        $header.css 'position', 'fixed'
        $header.css('top', 'auto')
        $header.css('bottom', h * (num_sections - $(header).data("order")))
        $header.addClass 'fixed_bot'
        $header.removeClass 'fixed_top'
      else
        $header.css('top', section_top - h)

# Adjusts the height of the arrow on page resize or scroll
arrowHeight = ->
  if show_scroll < 10 then return

  if $(window).width() < SIZE_CUTOFF
    if $("#arrow_body").height() < 20 then return
    else
      $("#arrow_body").animate
        height:"#20px"
      ,70
      return

  wh = $(window).height()
  dh = $(document).height()
  $arrow_body = $("#arrow_body")

  # We're scrolled near the bottom
  if $(window).scrollTop() + wh + 40 > dh
    arrow_height = 20
  else
    view_visible = wh/dh

    # When scrolled to the bottom, this is the relative percentage from the WINDOW top we want the arrow to start at.
    from_top = -0.666 * view_visible + 0.666

    # The percent down the page the user has scrolled
    scroll_percent = $(window).scrollTop() / (dh - wh)

    # The absolute position of where the arrowhead should end up. Affected by both window height and scroll position.
    doc_top = $(window).scrollTop() + scroll_percent * from_top * wh

    # Set the arrow height to a positive number
    arrow_height = Math.max($arrow_body.offset().top + $arrow_body.height() - doc_top, 10)
    $arrow_body.stop(true)

  $arrow_body.animate
    height:"#{arrow_height}px"
  ,70

fixCurriculum = ->
  # Position of the start of the sliding bar
  X_START = 40 + 128 - 10
  # End position of the sliding bar
  X_END = $("#page").width() - 30

  # How many pixels of scroll does it take to fully expand the bar
  EXP_LEN = 400

  bar_w = X_END - X_START - 15
  $(".bar").width(bar_w)

  if $(window).width() >= SIZE_CUTOFF
    scroll_top = $(window).scrollTop()
    for el in $(".bar_cover")
      factor = Math.min(Math.max(($(el).offset().top - scroll_top) / EXP_LEN, 0), 1)
      $(el).width(factor * bar_w)
  else
    $(".bar_cover").width bar_w

setFormErrorState = ->
  $(".form_error_area").show()
  $("#submit_application").html("Fix Errors & Try Again")
  onScroll()
clearFormErrorState = ->
  $(".form_error_area").hide()
  $("#submit_application").html("Submit Application")
  onScroll()

formSubmission = ->
  $(".help-inline").html ""
  if validateForm()
    data = $("#application").serializeObject()
    $.post "pages/wufoo", data, (r) ->
      if r.Success is 1
        submit_delta = Math.round((new Date().getTime() - instruction_show_time) / 1000)
        mpq.track("Submit Application Success", {"time_to_submit":submit_delta, "mp_note":"A user successfully submitted an application. They took #{submit_delta} seconds to fill it out."})

        $(window).scrollTop(0)
        $("#application").fadeOut ->
          onScroll()
        $("#success").fadeIn ->
          onScroll()
      else
        if r.FieldErrors?
          setFormErrorState()
          mpq.track("Submit Application Error", {"time_to_submit":submit_delta, "mp_note":"A user tried to submit an application but had errors. They took #{submit_delta} seconds to fill it out."})
          for error in r.FieldErrors
            id = $("input[name='app[#{error.ID}]'],textarea[name='app[#{error.ID}]']").attr('id')
            $("##{id}_error").html error.ErrorText
          onScroll()
  else
    setFormErrorState()
    submit_delta = Math.round((new Date().getTime() - instruction_show_time) / 1000)
    mpq.track("Submit Application Error", {"time_to_submit":submit_delta, "mp_note":"A user tried to submit an application but had errors. They took #{submit_delta} seconds to fill it out."})
    onScroll()
  return false

# Catch submission, validate, send it to wufoo backend and display results.
gettingStarted = ->
  data = $("#getting_started").serializeObject()
  console.log data
  $.post "pages/wufoo", data, (r) ->
    if r.Success is 1
      mpq.track("Submit Getting Started Success", {"mp_note":"A user successfully signed up."})

      showApplication()
      $("#awesome").show()
    else
      console.log "ERROR", r
      if r.FieldErrors?
        for error in r.FieldErrors
          id = $("input[name='app[#{error.ID}]']").attr('id')
          $("##{id}_error").html error.ErrorText
        onScroll()
  return false

window.showApplication = ->
  $("#application").slideDown 400, ->
    onScroll()
  $("#getting_started").slideUp()
  $("#instructions_container").fadeIn()
  $("#instructions").css('top', '-180px')
  $("#instructions").removeClass('opened')
  $("#email").val($("#getting_started_email").val())

window.hideApplication = ->
  $("#application").slideUp()
  $("#getting_started").slideDown 500, ->
    onScroll()
  $("#instructions_container").fadeOut()
  $("#instructions").css('top', '-180px')
  $("#instructions").removeClass('opened')
  $("#getting_started_email").val($("#email").val())
  onScroll()

# Custom front-end form validators
validateForm = ->
  num_errors = 0

  if $("#name").val().split(" ").length < 2
    num_errors += 1
    $("#name_error").html "Only 'Cher' can have one name. What's your FULL name?"
  if $("#name").val() is ""
    num_errors += 1
    $("#name_error").html "If you don't give us a name, we'll make one up for you (not)"

  if $("#email").val() is ""
    num_errors += 1
    $("#email_error").html "We need your email. How else would we get in touch with you"

  if $("input[type=radio]:checked").length is 0
    num_errors += 1
    $("#track_error").html "Please choose a track"

  if $("#whoami").val().length > 140
    num_errors += 1
    $("#whoami_error").html "Too many characters! Be concise please."
  if $("#whoami").val() is ""
    num_errors += 1
    $("#whoami_error").html "Please give us a short bio."

  if $("#social").val() is ""
    num_errors += 1
    $("#social_error").html "Give us some indication of stuff you've done"

  if $("#the_why").val() is ""
    num_errors += 1
    $("#the_why_error").html "Come on, aren't you interested?"

  if $("#accomplished").val() is ""
    num_errors += 1
    $("#accomplished_error").html "It can even be that volcano you built in 1st grade."

  if $("#good_hire").val().length > 250
    num_errors += 1
    $("#good_hire_error").html "Too many characters! Be concise please."
  if $("#good_hire").val() is ""
    num_errors += 1
    $("#good_hire_error").html "Please indicate some amount of awesomeness."

  if $("#other").val().split(" ").length > 250
    num_errors += 1
    $("#other_error").html "Too many words! Be concise please."

  if num_errors > 0
    return false
  else
    return true

# Limits the characters to `limit`
limitChar = (limit) ->
  c = ".#{$(@).attr("id")}_count"
  len = $(@).val().length

  if len > limit
    new_val = $(@).val().substr(0,limit)
    $(@).val new_val
    # So we show the correct length
    len -= 1

  $(c).html "#{len}/#{limit} characters"

# Limits the words to `limit`. Words are defined as any non blank text
# separated by a space.
limitWord = (limit) ->
  c = ".#{$(@).attr("id")}_count"
  word_arr = $(@).val().split(" ")
  # Remove white space array elements from split
  word_arr = word_arr.filter (word) ->
    if word == "" then false else true
  len = word_arr.length

  if len > limit
    crop = word_arr.slice(0,limit)
    new_val = crop.join(" ")
    $(@).val new_val
    # So we show the correct length
    len -= 1

  $(c).html "#{len}/#{limit} words"

# Helper method that turns the form into a nice javascript object
jQuery.fn.serializeObject = ->
  arrayData = @serializeArray()
  objectData = {}

  $.each arrayData, ->
    if @value? then value = @value else value = ''

    if objectData[@name]?
      unless objectData[@name].push
        objectData[@name] = [objectData[@name]]

      objectData[@name].push value
    else
      objectData[@name] = value

  return objectData

setupElements = ->
  # window.addEventListener 'SVGLoad', (e) ->
  #   adjustLogo()

  $(".section_header").show()

  $("#instructions").css
    top:"-#{$("#instruction_content").outerHeight()}px"
  # Need to make sure hidden container
  h = $("#instruction_header").outerHeight() + 10
  $("#instructions_container").height h

  # cta_t = $("#logo").outerHeight(true)
  # $("#call_to_action").css
  #   bottom:"#{cta_t - $("#call_to_action").outerHeight()}px"

  $("#page, #scroll_up").css
    visibility:"visible"

  $(window).scrollTop($(document).height())

  if $(window).width() < SIZE_CUTOFF
    $("#scroll_up").hide()

retrieveForm = ->
  if window.localStorage?
    for el in $("input[type=text], textarea")
      key = $(el).attr('name')
      val = localStorage.getItem key
      $(el).val(val)
  else 
    $(".no_save").show()
    return false

saveForm = ->
  if window.localStorage?
    for el in $("input[type=text], textarea")
      key = $(el).attr('name')
      val = $(el).val()
      localStorage.setItem key, val
  else return false

doNavColoring = ->
  page_top = $(window).scrollTop()
  page_bot = page_top + $(window).height()
  page_h = page_bot - page_top
  for section in $("section")
    sec_top = $(section).offset().top
    sec_bot = sec_top + $(section).outerHeight()
    sec_h = sec_bot - sec_top
    sec_id = $(section).attr("id")

    if sec_top - page_top < 0 and page_bot - sec_bot < 0
      # Div entirely in page and therefore 100%
      percent_showing = 1
    else
      percent_from_top = Math.min(sec_h, sec_bot - page_top) / sec_h
      percent_from_bot = Math.min(sec_h, page_bot - sec_top) / sec_h
      percent_showing = Math.min(percent_from_top, percent_from_bot)
      percent_showing = Math.max(percent_showing, 0)

    nav_opacity["nav_#{sec_id}"] = percent_showing

    $("#nav_#{sec_id}").find(".nav_bg").css
      opacity:percent_showing

events = ->
  # Bind resizing and scrolling
  $(window).resize onResize
  $(window).scroll onScroll

  $("input, textarea").blur saveForm
  $("input, textarea").focus clearFormErrorState

  $("#submit_getting_started").click ->
    console.log "GETTING STARTED CLICK"
    gettingStarted()
  $("#submit_application").click ->
    console.log "APPLICATION SUBMISSION CLICK"
    formSubmission()

  $("#whoami").keyup (e) ->
    limitChar.call(@, 140)

  $("#good_hire").keyup (e) ->
    limitChar.call(@, 250)

  $("#other").keyup (e) ->
    limitWord.call(@, 250)

  $(".section_header").click ->
    $section = $("##{$(@).data("section")}")
    correction = $(@).data("order") * $(@).height() + $(@).height()
    $("body,html").animate
      scrollTop: $section.offset().top - correction

  $(".show_application").click ->
    email = $("#getting_started_email").val()
    mpq.track("Show Application", {"user_email":email, "mp_note":"User with email #{email} viewed the full application"})
    showApplication()

  $(".hide_application").click hideApplication

  # $("#call_to_action").click ->
  #   scroll_pos = $(window).scrollTop() / ($(document).height() - $(window).height()) * 100
  #   mpq.track("Apply Now", {"scroll_pos":scroll_pos, "mp_note":"Sidebar Apply Now call to action clicked at #{scroll_pos}% on the page"})
  #   $section = $("#apply")
  #   correction = $(@).offset().top - $(window).scrollTop() + $(@).height()
  #   $("body,html").animate
  #     scrollTop: $section.offset().top - correction
  #   ,'slow'

  $(".instruction_toggle").click ->
    $instructions = $("#instructions")
    $container = $("#instructions_container")
    if $instructions.hasClass "opened"
      $instructions.animate
        top:"-#{$('#instruction_content').outerHeight()}px"
      , ->
        $container.height($("#instruction_header").outerHeight() + 10)
      $instructions.toggleClass "opened"
      $("#toggle_instructions").html "open"
    else
      h = $("#instruction_header").outerHeight() + $("#instruction_content").outerHeight() + 20
      $container.height h
      $instructions.animate
        top:"0px"
      $instructions.toggleClass "opened"
      $("#toggle_instructions").html "close"

  # NAVIGATION
  $("#floating_nav > ul > li").click ->
    $("html, body").animate
      scrollTop : $("##{$(@).data("section_id")}").offset().top
  $("#floating_nav > ul > li").hover ->
    $(@).find(".nav_bg").css
      opacity : 1
  , ->
    $(@).find(".nav_bg").css
      opacity : nav_opacity[$(@).attr("id")]

  $(window).scroll doNavColoring

jQuery ->

  # Setup the logo and arrow height for the first time
  events()
  onResize()

  retrieveForm()
  doNavColoring()

  $(window).scrollTop($(document).height())
