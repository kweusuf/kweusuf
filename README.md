<!-- Hover popup that works on GitHub -->
<div style="position: relative; display: inline-block; margin: 20px 0;">
  <a href="https://kweusuf.is-a.dev" style="text-decoration: none; display: block; position: relative;">
    <img src="./assets/resume-preview.jpg" alt="Resume Preview" title="🔗 Click to view full resume" style="width: 100%; max-width: 600px; height: auto; border: 2px solid #e1e4e8; border-radius: 6px; transition: all 0.2s ease; cursor: pointer;" onmouseover="this.style.borderColor='#0366d6'; this.style.boxShadow='0 4px 12px rgba(3,102,214,0.15)'; this.style.transform='scale(1.02)'; this.title='🔗 Click to view full resume - Opens in new tab'" onmouseout="this.style.borderColor='#e1e4e8'; this.style.boxShadow='none'; this.style.transform='scale(1)'; this.title='🔗 Click to view full resume'">
    <!-- Visible popup on hover -->
    <div style="position: absolute; top: -50px; left: 50%; transform: translateX(-50%); background: #0366d6; color: white; padding: 8px 16px; border-radius: 6px; font-size: 14px; white-space: nowrap; opacity: 0; pointer-events: none; transition: opacity 0.3s ease; z-index: 1000; box-shadow: 0 4px 12px rgba(0,0,0,0.15);">🔗 Click to view full resume</div>
  </a>
</div>

<script>
// Enhanced hover effect for better visibility
document.addEventListener('DOMContentLoaded', function() {
  var resumeImg = document.querySelector('img[alt="Resume Preview"]');
  var popup = resumeImg?.parentElement?.querySelector('div[style*="position: absolute"]');

  if (resumeImg && popup) {
    resumeImg.addEventListener('mouseenter', function() {
      popup.style.opacity = '1';
      popup.style.top = '-60px';
    });

    resumeImg.addEventListener('mouseleave', function() {
      popup.style.opacity = '0';
      popup.style.top = '-50px';
    });
  }
});
</script>

<!-- Alternative simple markdown version for maximum compatibility -->
<!--
[![Resume](./assets/resume-preview.jpg)](https://kweusuf.is-a.dev)
-->
