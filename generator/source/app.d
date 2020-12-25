module app;

import std.stdio;
import std.conv : to;
import std.string : format;
import requests : getContent;
import arsd.dom;
import generator.parser : TelegramBotApiHTMLParser;
import generator.generator : CodeGenerator;
import std.getopt : getopt, defaultGetoptPrinter;

string url = "https://core.telegram.org/bots/api";
string targetDir;

int main(string[] args)
{
    if (processHelp(args)) {
        return 0;
    }

    auto document = new Document(url.getContent.to!string);

    Element[] h3Items = document.querySelector("div[id=dev_page_content]").querySelectorAll("h3")
        // skipping "Recent changes", "Authorizing your bot", "Making requests", "Local server"
        [4..$];

    auto parser = new TelegramBotApiHTMLParser;

    foreach (Element el; h3Items) {
        parser.parseSection(el);
    }

    const targetDir = getTargetDir();
    writefln("Generating entities in %s", targetDir);
    auto generator = new CodeGenerator(targetDir);
    generator.generateFiles(parser.getEntities());

    return 0;
}

private string getTargetDir()
{
    import std.file : getcwd, isDir;
    import std.path : dirSeparator, buildPath;

    string path = buildPath(getcwd(), targetDir);
    assert(path.isDir, format("Path %s not found or is not a directory"));

    return path;
}

private bool processHelp(string[] args)
{
    auto helpInformation = getopt(
        args,
        "target-dir", "Relative path to generate files in", &targetDir,
        "url", "Telegram bot API documentation URL", &url
    );

    if (helpInformation.helpWanted) {
        defaultGetoptPrinter("Telegram bot API entities generator v. 0.1", helpInformation.options);

        return true;
    }

    return false;
}
