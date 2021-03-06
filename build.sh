#!/bin/bash -ex

# Builds new versions of client libraries using swagger-codegen
T="$(date +%s)"
DIR=`pwd`
CLIENTS=$DIR/clients
DOCS=$DIR/docs
CLI=$DIR/swagger-codegen/modules/swagger-codegen-cli/target/swagger-codegen-cli.jar
RESOURCES="https://www.bitmex.com/api/explorer/swagger.json"
declare -a CLIENTLANGS=(android async-scala clojure csharp dart java javascript go objc php python ruby scala swagger swagger-yaml typescript-fetch)
declare -a DOCLANGS=(html dynamic-html)

echo "Getting swagger json..."
rm $DIR/swagger.json || true
wget $RESOURCES

echo "Creating output folders..."
rm -rf $CLIENTS
rm -rf $DOCS
for clientLang in "${CLIENTLANGS[@]}"; do
  mkdir -p $CLIENTS/$clientLang
done

echo "Checking out newest swagger-codegen..."
git submodule init
git submodule update

echo "Building latest swagger-codegen..."
cd swagger-codegen
mvn package -DskipTests

echo "Generating client libraries..."
for clientLang in "${CLIENTLANGS[@]}"; do
  java -jar $CLI generate -i $DIR/swagger.json -l $clientLang -o $CLIENTS/$clientLang
done

echo "Generating static docs..."
for docLang in "${DOCLANGSS[@]}"; do
  java -jar $CLI generate -i $DIR/swagger.json -l $docLang -o $DOCS/$docLang
done

T="$(($(date +%s)-T))"
echo "Done in ${T} seconds."
