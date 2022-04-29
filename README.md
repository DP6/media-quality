# Media Quality

<div align="center">
<img src="https://raw.githubusercontent.com/DP6/templates-centro-de-inovacoes/main/public/images/centro_de_inovacao_dp6.png" height="100px" />
</div>

<p align="center">
  <a href="#badge">
    <img alt="semantic-release" src="https://img.shields.io/badge/%20%20%F0%9F%93%A6%F0%9F%9A%80-semantic--release-e10079.svg">
  </a>
  <a href="https://www.codacy.com/gh/DP6/9716857fbc5e46afae4724fd6ffc1709/dashboard?utm_source=github.com&amp;utm_medium=referral&amp;utm_content=DP6/template-js-cloudfunction-with-terraform&amp;utm_campaign=Badge_Coverage"><img alt="Code coverage" src="https://app.codacy.com/project/badge/Coverage/9716857fbc5e46afae4724fd6ffc1709"/></a>
  <a href="#badge">
    <img alt="Test" src="https://github.com/dp6/template-js-cloudfunction-with-terraform/actions/workflows/test.yml/badge.svg">
  </a>
  <a href="https://www.codacy.com/gh/DP6/template-js-cloudfunction-with-terraform/dashboard?utm_source=github.com&amp;utm_medium=referral&amp;utm_content=DP6/template-js-cloudfunction-with-terraform&amp;utm_campaign=Badge_Grade">
    <img alt="Code quality" src="https://app.codacy.com/project/badge/Grade/9716857fbc5e46afae4724fd6ffc1709">
  </a>
</p>

## Para que serve?

A solução de _Media Quality_ tem como objetivo acompanhar a volumetria de disparos das tags de mídia dentro do GTM, garantindo que modificações e atualizações no container não gere um impacto negativo no funcionamento das tags.

## Arquitetura de dados

Dados que serão enviados na ferramenta escolhida.

Dado coletado | Parâmetro
--- | --- 
media_name | Nome da mídia que foi disparada
tracking_id | Id de acompanhamento da mídia disparada
media_event | Nome do evento disparado
tag_name | Nome completo da tag disparada no GTM
status | Status de disparo da tag
datalayer_event | Nome do evento do DataLayer que acionou a tag

**Parâmetros adicionais:**

Os parâmetros adicionais serão enviados com o nome específico adicionado na tag do Media Quality do GTM.


## Como configurar?

- [Configuração com o uso do GA4](https://github.com/DP6/media-quality/blob/master/READM-GA4.md) (em desenvolvimento)
- [Configuração com o uso da Cloud Function](https://github.com/DP6/media-quality/blob/master/README-CLOUD-FUNCTION.md) (em desenvolvimento)

## Como contribuir

Pull requests são bem-vindos! Nós vamos adorar ajuda para evoluir esse modulo. Sinta-se livre para navegar por issues abertas buscando por algo que possa fazer. Caso tenha uma nova feature ou bug, por favor abra uma nova issue para ser acompanhada pelo nosso time.

### Requisitos obrigatórios

Só serão aceitas contribuições que estiverem seguindo os seguintes requisitos:

- [Padrão de commit](https://www.conventionalcommits.org/en/v1.0.0/)

### Api Docs

- [Index.md](https://github.com/dp6/media-quality/blob/master/docs/index.md)

## Suporte

**DP6 Koopa-troopa Team**

_e-mail: <koopas@dp6.com.br>_

<img src="https://raw.githubusercontent.com/DP6/templates-centro-de-inovacoes/main/public/images/koopa.png" height="100px" width=50px/>
