//
//  ViewController.swift
//  PromiseTestHydra
//
//  Created by 森田元亨 on 2019/07/11.
//  Copyright © 2019 森田元亨. All rights reserved.
//
// ※さらっとしてるけどわかりやすい記事
//♫ Title: Swift Hydra/Promiseで非同期処理を同期的に処理する | キャスレーコンサルティング株式会社
//　https://www.casleyconsulting.co.jp/blog/engineer/4413/
//
// ※ちょっとわかりにくいけど詳しい記事
//♫ Title: Swiftでasync/awaitな書き方もできるPromiseライブラリHydra - Qiita
//　https://qiita.com/hachinobu/items/fb7b3e52a7b9ee430496
//
// ※本家リポジトリ（英語）
//♫ Title: GitHub - malcommac/Hydra: Lightweight full-featured Promises, Async & Await Library in Swift
//　https://github.com/malcommac/Hydra

import UIKit
import Hydra

class ViewController: UIViewController {

    
    override func viewDidLoad() {
		super.viewDidLoad()

        print("はじめます : " + Thread.isMainThread.description)
        
        // メインスレッドで async ブロックを動かす時はこちら
        //async (in: .main) { _ -> Void in

        // メインでないスレッドで async ブロックを動かす時はこちら
        async { _ -> Void in
            print("async() : " + Thread.isMainThread.description)

            let res1 = try! await(self.proc1())
            print("res1: " + res1)

            let res2 = try! await(self.proc2())
            print("res2: " + res2)
            
            let res3 = try! await(self.proc3())
            print("res3: " + res3)
            
        }.then({_ in
            print("async の禅 : " + Thread.isMainThread.description)
        })
    }

    private func proc1() -> Promise<String> {
        print("proc1() : " + Thread.isMainThread.description)

        // メインスレッドで Promise ブロックを動かす時はこちら
        return Promise<String>(in: .main) { resolve, reject, _ in
            print("proc1() の約束 : " + Thread.isMainThread.description)
            
            // メインスレッドで Timer 動かす時は scheduledTimer() で動き出す
            Timer.scheduledTimer(withTimeInterval: 1, repeats: false, block: { (timer) in
                print("proc1() のタイマー : " + Thread.isMainThread.description)
                resolve("できた")
            })
        }
    }
    
    private func proc2() -> Promise<String> {
        print("proc2() : " + Thread.isMainThread.description)

        // この子もメインスレッド
        return Promise<String>(in: .main) { resolve, reject, _ in
            print("proc2() の約束 : " + Thread.isMainThread.description)

            // 動作スレッドによらず、Timer は生成するだけでは動作しない。
            let timer = Timer(timeInterval: 1.0, repeats: false, block: { (timer) in
                print("proc2() のタイマー : " + Thread.isMainThread.description)
                resolve("できたぴょん")
            })
            // 生成したインスタンスを「実行ループ」に「登録」すれば動き出す
            RunLoop.main.add(timer, forMode: RunLoop.Mode.default)
        }
    }
    
    private func proc3() -> Promise<String> {
        print("proc3() : " + Thread.isMainThread.description)

        // この子はメインじゃないスレッド
        return Promise<String>() { resolve, reject, _ in
            print("proc3() の約束 : " + Thread.isMainThread.description)

            // メインじゃないスレッドでも Timer は作れる
            let timer = Timer(timeInterval: 1.0, repeats: false, block: { (timer) in
                print("proc3() のタイマー : " + Thread.isMainThread.description)
                resolve("できたジョン！！")
            })
            // でもメインスレッドの実行ループに登録しないといけない
            RunLoop.main.add(timer, forMode: RunLoop.Mode.default)
        }
    }
}

