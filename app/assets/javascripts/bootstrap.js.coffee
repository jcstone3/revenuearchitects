jQuery ->
  $("a[rel=popover]").popover()
  $(".tooltip").tooltip({ container: 'body' })
  $("a[rel=tooltip]").tooltip({ container: 'body' })
  $("[rel=tooltip]").tooltip({ container: 'body' })
