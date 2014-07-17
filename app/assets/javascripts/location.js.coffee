jQuery ->
  $('form').on 'click', '.remove_fields_remote', (event) ->
    ($(this).closest('fieldset').next('input')).remove()
    ($(this).closest('fieldset')).remove()

  $('form').on 'click', '.remove_fields', (event) ->
    ($(this).closest('fieldset').next('input')).remove()
    ($(this).closest('fieldset')).remove()
    event.preventDefault()


  $('form').on 'click', '.add_fields', (event) ->
    time = new Date().getTime()
    regexp = new RegExp($(this).data('id'), 'g')
    $(this).before($(this).data('fields').replace(regexp, time))
    event.preventDefault()