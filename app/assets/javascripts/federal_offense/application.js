//= require rails-ujs

document.querySelectorAll("a[disabled]").forEach(function(link) {
  link.addEventListener("click", function(event) {
    event.preventDefault()
  })
})
