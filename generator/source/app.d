module app;

import std.stdio;
import std.conv : to;
import requests : getContent;
import arsd.dom;
import generator.parser : TelegramBotApiHTMLParser;
import generator.generator : CodeGenerator;

enum PAGE_URL = "https://core.telegram.org/bots/api";

int main()
{
    auto document = new Document(PAGE_URL.getContent.to!string);

    Element[] h3Items = document.querySelector("div[id=dev_page_content]").querySelectorAll("h3")
        // skipping "Recent changes", "Authorizing your bot", "Making requests", "Local server"
        [4..$];

    auto parser = new TelegramBotApiHTMLParser;

    foreach (Element el; h3Items) {
        parser.parseSection(el);
    }

    auto generator = new CodeGenerator;
    generator.generateFiles(parser.getEntities());

    return 0;
}
