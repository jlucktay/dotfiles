document.querySelectorAll("*[data-path*='vendor/']").forEach(el => {
  const item = el.querySelectorAll("input[type=checkbox][name=viewed]:not(:checked)")[0]
  if (typeof item !== "undefined") {
    setTimeout(function () {
      item.click()
    }, 1000)
  }
})
