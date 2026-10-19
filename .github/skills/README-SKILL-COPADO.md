No **Copilot Chat, em modo Agent**, copie um dos comandos abaixo. Mantenha a skill salva em `.github/skills/salesforce-copado-qa/SKILL.md`.

**1. Analisar o projeto**
```text
Use a skill salesforce-copado-qa para analisar este repositório. Identifique as bibliotecas Copado, estrutura dos testes, configurações e comandos de execução. Informe o que está pronto e o que falta para testar.
```

**2. Criar testes manuais**
```text
Use a skill salesforce-copado-qa para criar testes manuais da criação de uma Opportunity no Salesforce Lightning. Inclua cenários positivos, negativos, campos obrigatórios e permissões. Salve os casos em qa/manual/opportunity.md e marque todos como NOT_RUN.
```

**3. Testar uma história de usuário**
```text
Use a skill salesforce-copado-qa para analisar a história abaixo. Crie os casos manuais, a matriz de rastreabilidade e os testes automatizados Copado CRT dos cenários P0 e P1. Reutilize as bibliotecas e convenções deste projeto.

História:
[cole aqui a história e os critérios de aceite]
```

**4. Automatizar casos manuais existentes**
```text
Use a skill salesforce-copado-qa para automatizar os casos de qa/manual/opportunity.md com Copado CRT e Robot Framework. Reutilize resources e keywords existentes. Confirme as assinaturas das keywords antes de gerar código.
```

**5. Validar os testes sem executar a interface**
```text
Use a skill salesforce-copado-qa para validar a estrutura dos testes Robot Framework. Confira imports, variáveis e keywords e execute dry-run com a configuração do projeto. Informe os erros encontrados e corrija os que puder.
```

**6. Executar o smoke**
```text
Use a skill salesforce-copado-qa para executar os testes com tag smoke na sandbox de QA configurada neste projeto. Use o runner existente. Apresente resultados e caminhos das evidências reais. Se faltar acesso ou configuração, informe o bloqueio.
```

**7. Corrigir uma falha**
```text
Use a skill salesforce-copado-qa para analisar a falha abaixo. Investigue se a causa é produto, automação, dados ou ambiente. Corrija a causa identificada e execute novamente o teste afetado, preservando as asserções.

Falha:
[cole o log ou indique o arquivo]
```

**8. Testar permissões**
```text
Use a skill salesforce-copado-qa para criar uma matriz de testes de permissões do objeto Opportunity. Compare as personas disponíveis no projeto e cubra CRUD, field-level security e compartilhamento. Gere casos manuais e automatize os cenários viáveis.
```

**9. Revisar a automação existente**
```text
Use a skill salesforce-copado-qa para revisar os testes deste projeto. Identifique locators frágeis, esperas fixas, dependências entre testes, falta de asserções e problemas de limpeza de dados. Corrija os problemas de maior impacto e valide as alterações.
```

**Para começar, use o comando 1.** Depois, forneça uma história real usando o comando 3.


	Copie no **Copilot Chat em modo Agent** e substitua a URL:

```text
Use a skill salesforce-copado-qa para explorar o sistema em [COLE A URL] e gerar os casos de teste diretamente neste projeto.

1. Analise a estrutura do repositório e reutilize suas convenções.
2. Use as ferramentas de navegador disponíveis para acessar a URL. Se precisar de autenticação, permita que eu faça o login, sem solicitar minha senha no chat. Se não houver ferramenta de navegador, informe o recurso necessário.
3. Explore as telas, menus, formulários e jornadas acessíveis ao usuário autenticado. Faça um inventário das funcionalidades observadas.
4. Baseie os testes no comportamento observado e nos requisitos encontrados no projeto. Identifique regras inferidas como hipóteses a confirmar.
5. Gere casos positivos, negativos, de limites, validações e navegação. Para permissões, cubra somente as personas disponíveis e registre as demais como lacunas.
6. Salve os casos em qa/manual/, separados por funcionalidade, contendo ID, objetivo, pré-condições, dados, passos, resultado esperado, prioridade e status NOT_RUN.
7. Crie qa/traceability/exploration.md relacionando telas, funcionalidades e casos. Registre páginas inacessíveis e fluxos não explorados.
8. Crie qa/automation-candidates.md com os casos recomendados para automação Copado CRT, priorizados por risco e frequência de uso.

Explore sem alterar dados existentes. Faça operações de escrita somente em sandbox de testes autorizada, usando dados sintéticos identificáveis. Não exclua registros existentes, envie comunicações ou dispare pagamentos e integrações externas.

Não invente funcionalidades nem declare casos aprovados apenas por tê-los gerado. Continue até salvar os arquivos e apresente um resumo da cobertura e dos bloqueios.
```


