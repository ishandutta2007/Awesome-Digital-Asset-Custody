svg_content = """<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 800 200" width="100%" height="200">
  <defs>
    <linearGradient id="grad1" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" style="stop-color:#1e3c72;stop-opacity:1" />
      <stop offset="100%" style="stop-color:#2a5298;stop-opacity:1" />
    </linearGradient>
    <style>
      .title { font: bold 40px sans-serif; fill: #ffffff; }
      .subtitle { font: 20px sans-serif; fill: #a0c4ff; }
      @keyframes float {
        0% { transform: translateY(0px); }
        50% { transform: translateY(-10px); }
        100% { transform: translateY(0px); }
      }
      .floating { animation: float 3s ease-in-out infinite; }
    </style>
  </defs>
  <rect width="100%" height="100%" fill="url(#grad1)" rx="15" />
  <g class="floating" transform="translate(50, 100)">
    <text x="0" y="0" class="title">Awesome Digital Asset Custody</text>
    <text x="0" y="30" class="subtitle">Curated SaaS &amp; Open-Source Projects</text>
  </g>
  <!-- Simple decorative elements -->
  <circle cx="700" cy="50" r="20" fill="#ffffff" opacity="0.2" />
  <circle cx="750" cy="120" r="40" fill="#ffffff" opacity="0.1" />
</svg>"""

with open('assets/banner.svg', 'w', encoding='utf-8') as f:
    f.write(svg_content)
