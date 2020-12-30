module generator.generator;

import std.stdio : writeln, writefln;
import std.string : format;
import std.conv : to;
import generator.parser : TelegramEntity, TelegramType, TelegramMethod;
import std.array : join;
import std.algorithm.iteration : map, each;
import generator.language.declarations;
import generator.language.modules;
import generator.language.structs;

static string[string] entityModuleMap;

shared static this()
{
    string[] basic = [
        // types
        "User", "Chat", "Message", "Update",
        // methods
    ];
    string[] groupchat = [
        // types
        // methods
    ];
    string[] games = [
        // types
        "Game", "Animation", "CallbackGame", "GameHighScore",
        // methods
    ];

    basic.each!(val => entityModuleMap[val] = basic.stringof);
    games.each!(val => entityModuleMap[val] = games.stringof);
}

class CodeGenerator
{
    private string modulesDir = "telegram";

    public this(string modulesDir)
    {
        this.modulesDir = modulesDir;
    }

    public void generateFiles(TelegramEntity[string] entities)
    {
        foreach (entity; entities) {
            if (cast(TelegramType)entity) {
                generateType(cast(TelegramType)entity).writeln();
            } else if (cast(TelegramMethod)entity) {
                generateMethod(cast(TelegramMethod)entity).writeln();
            } else {
                assert(false, "Unknown entity " ~ entity.name);
            }
        }
        //writeln(entityModuleMap);
    }

    private string generateType(TelegramType entity)
    {
        auto item = new StructDeclaration(entity.name);

        return item.toString();
    }

    private string generateMethod(TelegramMethod entity)
    {
        return "TODO";
    }

}
