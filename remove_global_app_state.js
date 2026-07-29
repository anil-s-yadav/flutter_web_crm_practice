const fs = require('fs');
const path = require('path');

const libDir = path.join(__dirname, 'lib');

function processFile(filePath) {
    let content = fs.readFileSync(filePath, 'utf8');
    let original = content;

    content = content.replace(/import 'package:practice_app\/providers\/global_app_state\.dart';/g, 
        "import 'package:practice_app/blocs/auth/auth_bloc.dart';\nimport 'package:practice_app/blocs/auth/auth_state.dart';");

    content = content.replace(/final (appState|state) = Provider\.of<GlobalAppState>\(context(?:,\s*listen:\s*false)?\);/g, 
        "final $1 = context.read<AuthBloc>().state;");

    content = content.replace(/final (appState|state) = Provider\.of<GlobalAppState>\(context\);/g, 
        "final $1 = context.watch<AuthBloc>().state;");

    content = content.replace(/Provider\.of<GlobalAppState>\(context(?:,\s*listen:\s*false)?\)/g, 
        "context.read<AuthBloc>().state");

    content = content.replace(/Provider\.of<GlobalAppState>\(context\)/g, 
        "context.watch<AuthBloc>().state");

    content = content.replace(/GlobalAppState state,?/g, "");

    // User check replacements
    content = content.replace(/(appState|state)\.currentUser/g, "(($1 is AuthAuthenticated) ? ($1 as AuthAuthenticated).user : null)");

    if (content !== original) {
        fs.writeFileSync(filePath, content, 'utf8');
        console.log(`Updated ${filePath}`);
    }
}

function walkSync(dir, callback) {
    fs.readdirSync(dir).forEach(file => {
        let dirPath = path.join(dir, file);
        let isDirectory = fs.statSync(dirPath).isDirectory();
        if (isDirectory) {
            walkSync(dirPath, callback);
        } else if (dirPath.endsWith('.dart')) {
            callback(dirPath);
        }
    });
}

walkSync(libDir, processFile);
