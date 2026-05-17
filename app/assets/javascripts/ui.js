const initializeUiEnhancements = () => {
  document.querySelectorAll("[data-copy-text]").forEach((button) => {
    if (button.dataset.initialized === "true") return;
    button.dataset.initialized = "true";

    button.addEventListener("click", async () => {
      const text = button.dataset.copyText;
      const feedback = button.parentElement.querySelector("[data-copy-feedback]");
      const label = button.querySelector("span");
      const originalLabel = button.dataset.copyLabel || label?.textContent || "Copiar código";

      try {
        await navigator.clipboard.writeText(text);
        if (label) label.textContent = "Código copiado";
        if (feedback) feedback.classList.remove("hidden");

        window.setTimeout(() => {
          if (label) label.textContent = originalLabel;
          if (feedback) feedback.classList.add("hidden");
        }, 2000);
      } catch (_) {}
    });
  });

  document.querySelectorAll("[data-system-alert]").forEach((alert) => {
    if (alert.dataset.initialized === "true") return;
    alert.dataset.initialized = "true";

    const duration = Number(alert.dataset.alertDuration || 6000);
    const bar = alert.querySelector("[data-alert-bar]");

    if (bar) {
      requestAnimationFrame(() => {
        bar.style.transition = `width ${duration}ms linear`;
        bar.style.width = "0%";
      });
    }

    window.setTimeout(() => {
      alert.style.transition = "opacity 300ms ease, transform 300ms ease";
      alert.style.opacity = "0";
      alert.style.transform = "translateY(-8px)";
      window.setTimeout(() => alert.remove(), 300);
    }, duration);
  });
};

if (document.readyState === "loading") {
  document.addEventListener("DOMContentLoaded", initializeUiEnhancements);
} else {
  initializeUiEnhancements();
}

document.addEventListener("turbo:load", initializeUiEnhancements);
