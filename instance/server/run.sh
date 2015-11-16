elm make instance/server/Main.elm --output=instance/server/main.js
echo "Elm.worker(Elm.Main);" >> instance/server/main.js
node instance/server/main.js
