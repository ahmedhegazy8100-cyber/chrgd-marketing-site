document.addEventListener('DOMContentLoaded', function () {
  const hamburger = document.getElementById('hamburger');
  const nav = document.getElementById('mainNav');
  if (hamburger && nav) {
    hamburger.addEventListener('click', function () {
      const open = nav.classList.toggle('open');
      hamburger.setAttribute('aria-expanded', open);
    });
  }
});
