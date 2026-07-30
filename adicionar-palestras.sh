#!/bin/bash
set -e

echo "Rode este script na raiz do repositório do site (onde fica o hugo.toml)."

# 1. Pastas
mkdir -p content/palestras
mkdir -p layouts/palestras
mkdir -p layouts/partials

# 2. Página de listagem (front matter mínimo, o layout monta o resto)
cat > content/palestras/_index.md << 'EOF'
---
title: "Palestras"
---
EOF

# 3. Exemplo de palestra (draft: true -> não aparece publicada ainda)
#    Use este arquivo como modelo para as próximas: copie, renomeie e edite os campos.
cat > content/palestras/exemplo-palestra.md << 'EOF'
---
title: "Tema da palestra (exemplo)"
descricao: "Frase curta que aparece no card da listagem."
date: 2026-05-10
local: "Nome do evento, Joinville/SC"
video: "https://youtu.be/XXXXXXXXXXX"
materiais:
  - nome: "Slides da apresentação"
    url: "https://drive.google.com/SEU-LINK-AQUI"
  - nome: "Material de apoio"
    url: "https://drive.google.com/OUTRO-LINK-AQUI"
weight: 1
draft: true
---

Texto opcional com mais detalhes sobre a palestra, se quiser complementar a descrição curta.
EOF

# 4. Partial que extrai o ID do vídeo a partir de qualquer formato de link do YouTube
#    (watch?v=, youtu.be/, embed/, ou o próprio ID puro)
cat > layouts/partials/extrai-youtube-id.html << 'EOF'
{{ $url := . }}
{{ $id := $url }}
{{ if in $url "youtu.be/" }}
  {{ $id = index (split $url "youtu.be/") 1 }}
{{ else if in $url "v=" }}
  {{ $id = index (split (index (split $url "v=") 1) "&") 0 }}
{{ else if in $url "embed/" }}
  {{ $id = index (split $url "embed/") 1 }}
{{ end }}
{{ return $id }}
EOF

# 5. Layout da listagem (/palestras/)
cat > layouts/palestras/list.html << 'EOF'
{{ define "main" }}
<div class="secao-full tom-a">
<section class="lista-palestras">
  <h1>Palestras</h1>
  <p class="secao-intro">Vídeos e materiais de apoio das palestras que já apresentei.</p>

  <div class="grid-palestras">
    {{ range .Pages.ByDate.Reverse }}
    <article class="card-palestra">
      <a href="{{ .RelPermalink }}" class="card-palestra-link">
        {{ with .Params.video }}
        {{ $id := partial "extrai-youtube-id.html" . }}
        <div class="card-palestra-thumb" style="background-image:url('https://img.youtube.com/vi/{{ $id }}/hqdefault.jpg')"></div>
        {{ end }}
        {{ with .Date }}{{ $m := index (slice "" "janeiro" "fevereiro" "março" "abril" "maio" "junho" "julho" "agosto" "setembro" "outubro" "novembro" "dezembro") (int (.Format "1")) }}<p class="card-palestra-data">{{ .Format "2" }} de {{ $m }} de {{ .Format "2006" }}</p>{{ end }}
        <h2>{{ .Title }}</h2>
        {{ with .Params.local }}<p class="card-palestra-local">{{ . }}</p>{{ end }}
        <p>{{ .Params.descricao }}</p>
        <span class="leia-mais">VER PALESTRA</span>
      </a>
    </article>
    {{ end }}
  </div>
</section>
</div>
{{ end }}
EOF

# 6. Layout da página individual de cada palestra
cat > layouts/palestras/single.html << 'EOF'
{{ define "main" }}
<div class="secao-full tom-a">
<section class="pagina-palestra">
  <h1>{{ .Title }}</h1>
  {{ with .Date }}{{ $m := index (slice "" "janeiro" "fevereiro" "março" "abril" "maio" "junho" "julho" "agosto" "setembro" "outubro" "novembro" "dezembro") (int (.Format "1")) }}<p class="palestra-data-local">{{ .Format "2" }} de {{ $m }} de {{ .Format "2006" }}{{ with $.Params.local }} — {{ . }}{{ end }}</p>{{ end }}

  {{ with .Params.descricao }}<p class="palestra-descricao">{{ . }}</p>{{ end }}

  {{ with .Params.video }}
  {{ $id := partial "extrai-youtube-id.html" . }}
  <div class="video-responsivo">
    <iframe src="https://www.youtube.com/embed/{{ $id }}" title="{{ $.Title }}" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" allowfullscreen loading="lazy"></iframe>
  </div>
  {{ end }}

  {{ .Content }}

  {{ with .Params.materiais }}
  <div class="lista-materiais">
    <p class="relacionado-label">MATERIAIS DE APOIO</p>
    <ul>
      {{ range . }}
      <li><a href="{{ .url }}" target="_blank" rel="noopener">{{ .nome }}</a></li>
      {{ end }}
    </ul>
  </div>
  {{ end }}

  <p class="artigo-voltar"><a href="/palestras/">← Todas as palestras</a></p>
</section>
</div>
{{ end }}
EOF

# 7. Menu do header: adiciona o link "PALESTRAS" logo após "ARTIGOS"
sed -i 's#<a href="/artigos/">ARTIGOS</a>#<a href="/artigos/">ARTIGOS</a>\n    <a href="/palestras/">PALESTRAS</a>#' layouts/partials/header.html

# 8. Menu do footer: adiciona o link "Palestras" logo após "Artigos"
sed -i 's#<a href="/artigos/">Artigos</a>#<a href="/artigos/">Artigos</a>\n    <a href="/palestras/">Palestras</a>#' layouts/partials/footer.html

echo ""
echo "Pronto. Rode 'hugo server' para conferir em /palestras/ antes de publicar."
echo "O arquivo content/palestras/exemplo-palestra.md está com 'draft: true' (não publica)."
echo "Copie e edite esse arquivo para cada palestra real, e apague-o quando não precisar mais dele de referência."
