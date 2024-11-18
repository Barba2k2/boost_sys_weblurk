#!/bin/bash

# Tenta obter a última tag, se falhar assume que é o primeiro release
LATEST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || echo "v1.0.0")

# Verifica se obteve uma tag válida
if [[ ! $LATEST_TAG =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo "Warning: Tag inválida ou não encontrada. Iniciando da v1.0.1"
    NEW_TAG="v1.0.1"
else
    # Extrai os números da versão usando regex para maior segurança
    if [[ $LATEST_TAG =~ ^v([0-9]+)\.([0-9]+)\.([0-9]+)$ ]]; then
        V_MAJOR="${BASH_REMATCH[1]}"
        V_MINOR="${BASH_REMATCH[2]}"
        V_PATCH="${BASH_REMATCH[3]}"
        
        # Incrementa o patch
        V_PATCH=$((V_PATCH + 1))
        
        NEW_TAG="v${V_MAJOR}.${V_MINOR}.${V_PATCH}"
    else
        echo "Error: Formato de tag inválido. Usando v1.0.1"
        NEW_TAG="v1.0.1"
    fi
fi

# Exibe informações para debug
echo "Tag anterior: $LATEST_TAG"
echo "Nova tag: $NEW_TAG"

# Exporta para o GitHub Actions
echo "NEW_TAG=$NEW_TAG" >> $GITHUB_ENV