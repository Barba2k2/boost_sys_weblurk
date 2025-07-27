#!/bin/bash

# Função para extrair versão do pubspec.yaml
extract_version_from_pubspec() {
    local version_line=$(grep "^version:" pubspec.yaml | head -1)
    if [[ $version_line =~ version:[[:space:]]*([0-9]+\.[0-9]+\.[0-9]+)\+([0-9]+) ]]; then
        echo "${BASH_REMATCH[1]}+${BASH_REMATCH[2]}"
    else
        echo "1.0.0+1"
    fi
}

# Função para extrair apenas a versão sem build number
extract_version_only() {
    local version_line=$(grep "^version:" pubspec.yaml | head -1)
    if [[ $version_line =~ version:[[:space:]]*([0-9]+\.[0-9]+\.[0-9]+) ]]; then
        echo "${BASH_REMATCH[1]}"
    else
        echo "1.0.0"
    fi
}

# Função para extrair apenas o build number
extract_build_number() {
    local version_line=$(grep "^version:" pubspec.yaml | head -1)
    if [[ $version_line =~ version:[[:space:]]*[0-9]+\.[0-9]+\.[0-9]+\+([0-9]+) ]]; then
        echo "${BASH_REMATCH[1]}"
    else
        echo "1"
    fi
}

# Obter versão atual do pubspec.yaml
CURRENT_VERSION=$(extract_version_from_pubspec)
CURRENT_VERSION_ONLY=$(extract_version_only)
CURRENT_BUILD=$(extract_build_number)

# Incrementar o build number
NEW_BUILD=$((CURRENT_BUILD + 1))
NEW_VERSION="${CURRENT_VERSION_ONLY}+${NEW_BUILD}"

# Criar tag no formato vX.Y.Z
NEW_TAG="v${CURRENT_VERSION_ONLY}"

# Exibe informações para debug
echo "Versão atual do pubspec: $CURRENT_VERSION"
echo "Versão sem build: $CURRENT_VERSION_ONLY"
echo "Build atual: $CURRENT_BUILD"
echo "Novo build: $NEW_BUILD"
echo "Nova versão: $NEW_VERSION"
echo "Nova tag: $NEW_TAG"

# Exporta para o GitHub Actions (se disponível)
if [ -n "$GITHUB_ENV" ]; then
    echo "NEW_TAG=$NEW_TAG" >> $GITHUB_ENV
    echo "NEW_VERSION=$NEW_VERSION" >> $GITHUB_ENV
    echo "NEW_BUILD=$NEW_BUILD" >> $GITHUB_ENV
    echo "CURRENT_VERSION_ONLY=$CURRENT_VERSION_ONLY" >> $GITHUB_ENV
    echo "Variáveis exportadas para GitHub Actions"
else
    echo "GITHUB_ENV não disponível (executando localmente)"
    echo "NEW_TAG=$NEW_TAG"
    echo "NEW_VERSION=$NEW_VERSION"
    echo "NEW_BUILD=$NEW_BUILD"
    echo "CURRENT_VERSION_ONLY=$CURRENT_VERSION_ONLY"
fi