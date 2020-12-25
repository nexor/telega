module generator.generator;

import std.stdio : writeln, writefln;
import generator.parser : TelegramEntity;
import std.array : assocArray;
import std.algorithm.iteration;

static string[string] entityModuleMap;

shared static this()
{
    string[] basic = [
        // types
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

    games.each!(val => entityModuleMap[val] = games.stringof);
}

class CodeGenerator
{
    public void generateFiles(TelegramEntity[string] entities)
    {
        writeln("Generating files ...");
        writeln(entityModuleMap);
    }
}
