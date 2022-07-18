# Configuração com o uso do GA4
No Google Analytics 4 deve ser criada uma conta e um fluxo de dados. O valor do *MEASUREMENT ID* deve ser utilizado no GTM para o envio das informações. 
 
## Declaração de custom dimensions
Para que algumas informações dos eventos de mídia sejam utilizadas no relatórios do GA4 é necessário registrá-las como dimensões personalizadas. Para criar uma dimensão personalizada vá em `Configure > Custom Definitions > Create custom dimensions`. Foram criadas dimensões para os parâmetros `media_event`, `media_name` e `status`.

<div align="center">
<img src="./documentation-images/ga4-custom-dimension.png" height="auto" />
<figcaption>Figura 1 - Criação de dimensões personalizadas no GA4</figcaption>
</div>
