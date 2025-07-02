# 🚀 BoostTwitch - Painel de Agendamento

Um aplicativo Flutter desktop para gerenciamento de agendamentos de streamers com interface moderna e funcionalidades avançadas.

## ✨ Funcionalidades

### 🔐 Autenticação Segura

- Sistema de login com JWT
- Confirmação de login para web e Windows
- Refresh automático de tokens
- Logout automático em caso de sessão expirada

### 📅 Gerenciamento de Agendamentos

- **Listas A e B separadas** com endpoints dedicados
- Visualização em tempo real dos agendamentos
- Cache inteligente para melhor performance
- Debounce para evitar requisições duplicadas

### 🌐 WebView Integrado

- Navegador embutido para visualização de streams
- Monitoramento automático de saúde do WebView
- Recuperação automática em caso de problemas
- Suporte a múltiplas abas (Lista A e Lista B)

### 🎨 Interface Moderna

- **Material 3** com design atualizado
- **Dark Mode** automático baseado no sistema
- **Responsivo** para diferentes tamanhos de tela
- **Acessível** com suporte a leitores de tela

### ⚡ Performance Otimizada

- Cache em memória para agendamentos
- Debounce de 300ms para troca de abas
- Loaders informativos para operações longas
- Tratamento robusto de erros

## 🛠️ Tecnologias Utilizadas

- **Flutter** 3.5.0+
- **MobX** para gerenciamento de estado
- **Flutter Modular** para injeção de dependência
- **Dio** para requisições HTTP
- **WebView Windows** para navegador embutido
- **Material 3** para design moderno

## 📋 Pré-requisitos

- Flutter SDK 3.5.0 ou superior
- Dart 3.4.0 ou superior
- Windows 10/11 (para versão desktop)
- Conexão com internet

## 🚀 Instalação e Configuração

### 1. Clone o repositório

```bash
git clone https://github.com/seu-usuario/boost_sys_weblurk.git
cd boost_sys_weblurk
```

### 2. Instale as dependências

```bash
flutter pub get
```

### 3. Configure as variáveis de ambiente

Crie um arquivo `.env` na raiz do projeto:

```env
base_url=https://api.boostapi.com.br
rest_client_connect_timeout=60000
rest_client_receive_timeout=60000
```

### 4. Execute o aplicativo

```bash
flutter run -d windows
```

## 🏗️ Estrutura do Projeto

```
lib/
├── app/
│   ├── core/                    # Núcleo da aplicação
│   │   ├── exceptions/          # Exceções customizadas
│   │   ├── helpers/             # Utilitários e constantes
│   │   ├── logger/              # Sistema de logs
│   │   ├── rest_client/         # Cliente HTTP com interceptors
│   │   ├── ui/                  # Widgets e configurações de UI
│   │   └── local_storage/       # Armazenamento local seguro
│   ├── models/                  # Modelos de dados tipados
│   ├── modules/                 # Módulos da aplicação
│   │   └── core/
│   │       └── auth/            # Autenticação e home
│   ├── repositories/            # Camada de acesso a dados
│   └── service/                 # Serviços de negócio
└── main.dart                    # Ponto de entrada
```

## 🎯 Principais Melhorias Implementadas

### 1. **Tipagem Forte**

- Modelos `ScheduleModel` e `ScheduleListModel` com tipagem completa
- Eliminação de `Map<String, dynamic>` em favor de classes tipadas
- Melhor autocompletação e prevenção de erros

### 2. **Tratamento de Erros Aprimorado**

- Mensagens de erro específicas e amigáveis
- Loaders informativos para operações longas
- Sugestões de retry para falhas de rede
- Tratamento diferenciado por tipo de erro

### 3. **Performance e UX**

- Cache de 5 minutos para canais
- Debounce de 300ms para troca de abas
- Monitoramento automático de saúde do WebView
- Recuperação automática de problemas

### 4. **Interface Moderna**

- Material 3 com design atualizado
- Dark mode automático
- Suporte a tamanho de fonte ajustável
- Melhor contraste e acessibilidade

### 5. **Acessibilidade**

- Labels semânticos para leitores de tela
- Suporte a navegação por teclado
- Contraste adequado
- Tamanho de fonte responsivo

## 🔧 Configuração de Desenvolvimento

### Gerar código MobX

```bash
flutter packages pub run build_runner build
```

### Executar testes

```bash
flutter test
```

### Análise de código

```bash
flutter analyze
```

## 📱 Funcionalidades por Módulo

### Autenticação (`/auth/`)

- Login com nickname e senha
- Confirmação de login (web/Windows)
- Refresh automático de tokens
- Logout seguro

### Home (`/home/`)

- Visualização de agendamentos em abas
- WebView integrado para streams
- Monitoramento de saúde
- Recuperação automática

## 🐛 Solução de Problemas

### WebView não carrega

- Verifique a conexão com a internet
- Tente recarregar a página (botão flutuante)
- Reinicie o aplicativo se o problema persistir

### Erro de autenticação

- Faça logout e login novamente
- Verifique se as credenciais estão corretas
- Entre em contato com o suporte se necessário

### Performance lenta

- O cache é limpo automaticamente a cada 5 minutos
- Troque de aba com calma para evitar requisições duplicadas
- Verifique sua conexão com a internet

## 🤝 Contribuindo

1. Fork o projeto
2. Crie uma branch para sua feature (`git checkout -b feature/AmazingFeature`)
3. Commit suas mudanças (`git commit -m 'Add some AmazingFeature'`)
4. Push para a branch (`git push origin feature/AmazingFeature`)
5. Abra um Pull Request

## 📄 Licença

Este projeto está sob a licença MIT. Veja o arquivo `LICENSE` para mais detalhes.

## 📞 Suporte

Para dúvidas, sugestões ou problemas:

- Abra uma issue no GitHub
- Entre em contato com a equipe de desenvolvimento

---

**Versão:** 1.0.2  
**Última atualização:** Janeiro 2024  
**Compatibilidade:** Windows 10/11, Flutter 3.5.0+
