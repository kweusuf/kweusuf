<div class="image-container">
  <a href="https://kweusuf.is-a.dev" class="image-link">
    <img src="./assets/resume-preview.jpg" alt="Resume" class="resume-image">
    <div class="popup">Click to view full resume</div>
  </a>
</div>

<style>
.image-container {
  position: relative;
  display: inline-block;
}

.image-link {
  position: relative;
  text-decoration: none;
}

.resume-image {
  width: 100%;
  max-width: 800px;
  height: auto;
  transition: filter 0.3s ease;
  cursor: pointer;
}

.popup {
  position: absolute;
  bottom: 100%;
  left: 50%;
  transform: translateX(-50%);
  background-color: rgba(0, 0, 0, 0.8);
  color: white;
  padding: 8px 12px;
  border-radius: 4px;
  font-size: 14px;
  white-space: nowrap;
  opacity: 0;
  pointer-events: none;
  transition: opacity 0.3s ease;
  z-index: 1000;
}

.image-container:hover .popup {
  opacity: 1;
}

.image-container:hover .resume-image {
  filter: brightness(1.1);
}
</style>
