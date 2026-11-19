// Served from Examples/DemoServer/Public by Vapor's FileMiddleware.
// Loaded with `defer`, so the page has been parsed when this runs.
document.querySelectorAll("[data-js-status]").forEach((element) => {
  element.textContent = "page-setup.js ran after the page was parsed.";
});
