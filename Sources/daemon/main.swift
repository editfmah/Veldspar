//    MIT License
//
//    Copyright (c) 2018 Veldspar Team
//
//    Permission is hereby granted, free of charge, to any person obtaining a copy
//    of this software and associated documentation files (the "Software"), to deal
//    in the Software without restriction, including without limitation the rights
//    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//    copies of the Software, and to permit persons to whom the Software is
//    furnished to do so, subject to the following conditions:
//
//    The above copyright notice and this permission notice shall be included in all
//    copies or substantial portions of the Software.
//
//    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//    SOFTWARE.

import Foundation
import VeldsparCore
import Swifter

// defaults
var port: Int = 14242

print("---------------------------")
print("\(Config.CurrencyName) Daemon v\(Config.Version)")
print("---------------------------")

var cacheSize = 128*1024
var isGenesis = false
let args: [String] = CommandLine.arguments

if args.count > 1 {
    for arg in args {
        if arg.lowercased() == "--help" {
            print("\(Config.CurrencyName) - v\(Config.Version)")
            print("-----   COMMANDS -------")
            print("--debug          : enables debug output to console")
            exit(0)
        }
        if arg.lowercased() == "--debug" {
            debug_on = true
        }
        if arg.lowercased() == "--genesis" {
            // setup the blockchain with an empty block starting the generation of Ore
            isGenesis = true
        }
        if arg.lowercased() == "--cache64" {
            cacheSize = 64*1024
        }
        if arg.lowercased() == "--cache128" {
            cacheSize = 128*1024
        }
        if arg.lowercased() == "--cache256" {
            cacheSize = 256*1024
        }
        if arg.lowercased() == "--cache512" {
            cacheSize = 512*1024
        }
        if arg.lowercased() == "--cache768" {
            cacheSize = 768*1024
        }
        if arg.lowercased() == "--cache1024" {
            cacheSize = 1024*1024
        }
    }
}

let ore = Ore(Config.GenesisID, height: 0)

let v3Beans = AlgorithmSHA512AppendV0.beans()

// open the database connection
Database.Initialize()

let logger = Logger()
print("Database(s) opened (blockchain, pending, log)")
var blockchain = BlockChain()

if isGenesis {
    if blockchain.blockAtHeight(0) != nil {
        print("Genesis block has already been created, exiting.")
        exit(0)
    }
    
    var firstBlock = Block()
    firstBlock.height = 0
    firstBlock.oreSeed = Config.GenesisID
    firstBlock.transactions = []
    firstBlock.hash = firstBlock.GenerateHashForBlock(previousHash: "")
    if(!Database.WriteBlock(firstBlock)) {
        print("Unable to write initial genesis block into the blockchain.")
        exit(0)
    }
}

print("Blockchain created, currently at height \(blockchain.height())")

Execute.background {
    for i in 0...Int(blockchain.height()) {
        BlockMaker.export_block(i)
    }
}
    
Execute.background {
    // endlessly run the main process loop
    BlockMaker.Loop()
}

Execute.background {
    process_registrations()
}

// now start the webserver and block
RPCServer.start()

let waiter = DispatchSemaphore(value: 0)
waiter.wait()
