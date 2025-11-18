#!/bin/bash
set -euo pipefail

# Colores
GREEN="\e[32m"
RED="\e[31m"
YELLOW="\e[33m"
BLUE="\e[34m"
NC="\e[0m"   # No Color / reset

# Verificar que kubectl exista
if ! command -v kubectl >/dev/null 2>&1; then
  echo -e "${RED}❌ kubectl no está instalado o no está en el PATH${NC}"
  exit 1
fi

read -p "Nombre actual (OLD, ej. my-app8): " OLD
read -p "Nombre nuevo  (NEW, ej. my-app9): " NEW

DEPLOY_FILE="deployment.yml"
SERVICE_FILE="service.yml"

if [ -z "${OLD}" ] || [ -z "${NEW}" ]; then
  echo -e "${RED}❌ OLD y NEW son requeridos${NC}"
  exit 1
fi

for FILE in "${DEPLOY_FILE}" "${SERVICE_FILE}"; do
  if [ ! -f "${FILE}" ]; then
    echo -e "${YELLOW}⚠️  No se encontró ${FILE}, se omite.${NC}"
    continue
  fi

  echo -e "${BLUE}📄 Procesando ${FILE}...${NC}"
  cp "${FILE}" "${FILE}.bak"

  # Si sed falla por algo, el set -e hace que el script termine
  sed -i "s/${OLD}/${NEW}/g" "${FILE}"

  echo -e "${GREEN}✅ Renombrado en ${FILE} (backup: ${FILE}.bak)${NC}"
done

echo -e "${BLUE}🔍 Validando en el cluster...${NC}"

# Verifica si existen recursos con el nombre viejo y nuevo
echo -e "${YELLOW}➡️  Antes (OLD):${NC}"
if ! kubectl get deploy "${OLD}" 2>/dev/null; then
  echo -e "  ${YELLOW}(no había deployment ${OLD})${NC}"
fi
if ! kubectl get svc "${OLD}" 2>/dev/null; then
  echo -e "  ${YELLOW}(no había service ${OLD})${NC}"
fi

echo -e "${YELLOW}➡️  Después (NEW):${NC}"
if ! kubectl get deploy "${NEW}" 2>/dev/null; then
  echo -e "  ${YELLOW}(no hay deployment ${NEW} todavía)${NC}"
fi
if ! kubectl get svc "${NEW}" 2>/dev/null; then
  echo -e "  ${YELLOW}(no hay service ${NEW} todavía)${NC}"
fi

echo -e "${BLUE}ℹ️  Si acabas de cambiar solo los YAML, recuerda aplicar:${NC}"
echo -e "    kubectl apply -f ${DEPLOY_FILE}"
echo -e "    kubectl apply -f ${SERVICE_FILE}"

