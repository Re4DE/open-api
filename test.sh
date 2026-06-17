set -euo pipefail

SPECS_DIR="specs"
OUTPUT_DIR="docs/_swagger/specs"
CONFIG_FILE="docs/_swagger/swagger-config.json"

echo "==> Cleaning specs output directory"
rm -rf "${OUTPUT_DIR}"
mkdir -p "${OUTPUT_DIR}"

echo "==> Copying spec files and building config"

# Start JSON
echo '{"urls": [' > "${CONFIG_FILE}"

first=true
find "${SPECS_DIR}" -type f \( -name "*.yaml" -o -name "*.yml" \) | sort | while read -r file; do
  # Flatten: specs/1-connector/management-api.yaml -> 1-connector-management-api.yaml
  relative="${file#${SPECS_DIR}/}"
  flat_name=$(echo "${relative}" | sed 's|/|-|g')

  # Readable name: "Connector / Management Api"
  repo_part=$(echo "${relative}" | cut -d'/' -f1 | sed 's|^[0-9]*-||; s|-| |g')
  api_part=$(basename "${relative}" | sed 's|\.ya\?ml$||; s|-| |g')
  display_name="${repo_part^} / ${api_part^}"

  cp "$file" "${OUTPUT_DIR}/${flat_name}"

  if [ "$first" = true ]; then
    first=false
  else
    echo ',' >> "${CONFIG_FILE}"
  fi
  printf '  {"url": "specs/%s", "name": "%s"}' "${flat_name}" "${display_name}" >> "${CONFIG_FILE}"
done

echo '' >> "${CONFIG_FILE}"
echo ']}' >> "${CONFIG_FILE}"

echo "==> Generated config:"
cat "${CONFIG_FILE}"

echo ""
echo "==> Copied specs:"
ls -la "${OUTPUT_DIR}"