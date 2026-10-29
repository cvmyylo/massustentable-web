/* +Sustentable — landing (massustentable.cl). JS vainilla, sin dependencias. */

/* Logo del header: volver arriba con scroll suave (antes era un onclick inline) */
(function(){
  var brand = document.getElementById('brandLink');
  if(!brand) return;
  brand.addEventListener('click', function(e){
    e.preventDefault();
    window.scrollTo({top:0, behavior:'smooth'});
  });
})();

/* Slider de banners: flechas, dots, autoplay cada 7 s y alto adaptable en mobile */
(function(){
  var slider = document.querySelector('.slider');
  var track = document.getElementById('sliderTrack');
  var dots = Array.prototype.slice.call(document.querySelectorAll('.dot'));
  var prevBtn = document.getElementById('prevArrow');
  var nextBtn = document.getElementById('nextArrow');
  if(!slider || !track || !dots.length) return;
  var idx = 0, timer = null;
  var reduceMotion = window.matchMedia && window.matchMedia('(prefers-reduced-motion: reduce)').matches;
  var mq = window.matchMedia('(max-width:860px)');

  function syncHeight(){
    if(mq.matches){
      var active = track.children[idx];
      if(active){
        var inner = active.querySelector('.card-inner');
        var h = inner ? inner.offsetHeight : active.offsetHeight;
        slider.style.height = h + 'px';
      }
    } else {
      slider.style.height = '';
    }
  }
  function goTo(i){
    idx = (i + dots.length) % dots.length;
    track.style.transform = 'translateX(-' + (idx * 100) + '%)';
    dots.forEach(function(d, j){ d.classList.toggle('active', j === idx); });
    syncHeight();
  }
  function autoplay(){
    if(reduceMotion) return;
    timer = setInterval(function(){ goTo(idx + 1); }, 7000);
  }
  function resetAutoplay(){ clearInterval(timer); autoplay(); }

  dots.forEach(function(d, i){
    d.addEventListener('click', function(){ goTo(i); resetAutoplay(); });
  });
  if(prevBtn) prevBtn.addEventListener('click', function(){ goTo(idx - 1); resetAutoplay(); });
  if(nextBtn) nextBtn.addEventListener('click', function(){ goTo(idx + 1); resetAutoplay(); });
  window.addEventListener('resize', syncHeight);
  window.addEventListener('load', syncHeight);
  syncHeight();
  autoplay();
})();
