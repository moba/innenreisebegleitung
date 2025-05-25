document.querySelectorAll("img").forEach((img) => {
  let touched = false;

  img.addEventListener("touchstart", () => {
    img.classList.add("colored");
    touched = true;

    // Optional: remove color after a while (simulate "unhover")
    setTimeout(() => {
      img.classList.remove("colored");
      touched = false;
    }, 5000); // stays colored for 5 seconds (adjust as needed)
  });
});
