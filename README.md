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

A solução _Media Quality_ tem como objetivo acompanhar a saúde e volumetria de disparos das tags de mídia dentro do GTM, garantindo que modificações e atualizações no container não gere um impacto negativo no funcionamento das tags, tornando ágil o processo de identificação e correção de comportamentos inesperados na coleta de mídia. Os dados dos eventos podem ser enviados para o Google Analytics 4 ou para o BigQuery, através do uso do Google Cloud Functions.

## Arquitetura de dados

Quando uma tag de mídia é disparada, a tag de Media Quality é acionada e envia os dados do evento para o GA4 e/ou cloud function. Enquanto os dados dos eventos no GA4 somente ficam disponíveis no dia seguinte, com a utilização de cloud functions o monitoramento ocorre em tempo real.

> O uso do Cloud Function é mais indicado para verificação de dados em tempo real. Os dados no GA4 ficam disponibilizados em um dia após a implementação, podendo ser integrados a outros relatórios. Caso queira, as duas opções podem ser configuradas e utilizadas ao mesmo tempo.

O fluxo de implementação da solução funciona da seguinte forma:

1. inicialmente são criadas as contas do GA4 e no GTM;
2. Importação do template de tag customizado para o GTM;
3. Criação de fluxo de dados no GA4 e obtenção do _MEASUREMENT ID_ (apenas se for utilizar o GA4);
4. Criação de cloud function no ambiente em nuvem da Google;
5. Criação de tabela de Media Quality no Big Query;
6. Criação das tags de configuração do Media Quality utilizando o template customizado;
7. Criação de disparador das tags;
8. Adição de parâmetros nas tags de mídia existentes, para que estas sejam rastreadas;
9. Construção de relatórios a partir das tabelas do Big Query.

Dados de mídia que serão enviados na ferramenta escolhida.

| Dado coletado   | Parâmetro                                     |
| :-------------- | :-------------------------------------------- |
| media_name      | Nome da mídia que foi disparada               |
| tracking_id     | Id de acompanhamento da mídia disparada       |
| media_event     | Nome do evento disparado                      |
| tag_name        | Nome completo da tag disparada no GTM         |
| status          | Status de disparo da tag                      |
| datalayer_event | Nome do evento do DataLayer que acionou a tag |
| client_id       | Id do cliente                                 |
| timestamp       | Data e hora do disparo                        |

**Parâmetros adicionais:**

Os parâmetros adicionais serão enviados com o nome específico adicionado na tag do Media Quality do GTM.

## Implementação no Google Analytics 4

### **Requisitos para utilização**

- Google Tag Manager (GTM);
- Google Analytics 4.

### **Configurações**

A seguir são listadas algumas etapas de configuração:

1. [Configuração do GTM](https://github.com/DP6/media-quality/blob/master/README-GTM.md);
2. [Configuração com o uso do GA4](https://github.com/DP6/media-quality/blob/master/README-GA4.md);

## Implementação com Google Cloud Function

### **Requisitos para utilização**

- Cloud Function;
- Bigquery;
- Google Tag Manager (GTM);

### **Configurações**

A seguir são listadas algumas etapas de configuração:

1. [Configuração do GTM](https://github.com/DP6/media-quality/blob/master/README-GTM.md);
2. [Configuração com o uso da Cloud Function](https://github.com/DP6/media-quality/blob/master/README-CLOUD-FUNCTION.md);

Opcional:

3. [Configuração de coleta de informações sobre tags existentes no GTM](https://github.com/DP6/media-quality/blob/master/README-GTM-API.md).

## Dashboard de acompanhamento

Os dados armazenados na tabela do Big Query foram utilizados para a criação de dashbords no Data Studio. Os dados são exibidos quase em tempo real (atualizados a cada 15 minutos) e permitem agilidade na análise e tomada de decisão em relação ao comportamento das tags de mídia.

### Página de acompanhamento real-time

<img src="./documentation-images/dashboard-real-time.gif" height="auto" width="auto"/>

### Página de análise de consolidado

<img src="./documentation-images/dashboard-consolidated.gif" height="auto" width="auto"/>

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
