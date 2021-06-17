//
//  tvViewController.swift
//  TVChat
//
//  Created by Satoshi Yokokawa on 2021/06/12.
//  Copyright © 2021 Satoshi Yokokawa. All rights reserved.
//

import UIKit
import Firebase

class ChatRoomViewController: UIViewController, UISearchBarDelegate {
    var countKeybord:Int = 3
    var searchBarButtonItem: UIBarButtonItem!      // +ボタン
    var tv: Tv?
    var searchText: String = ""
    let maxLength: Int = 10
    private let cellId = "cellId"
    private var messages = [Message]()
    private let accessoryHeight: CGFloat = 100
    private let tableViewContentInset: UIEdgeInsets = .init(top: 60, left: 0, bottom: 0, right: 0)
    private let tableViewIndicatorInset: UIEdgeInsets = .init(top: 60, left: 0, bottom: 0, right: 0)
    private var safeAreaBottom: CGFloat {
        self.view.safeAreaInsets.bottom
    }
        
    private lazy var chatInputAccessoryView: ChatInputAccessoryView = {
        let view = ChatInputAccessoryView()
        view.frame = .init(x: 0, y: 0, width: view.frame.width, height: accessoryHeight)
        view.delegate = self
        return view
    }()
    
    @IBOutlet weak var chatRoomTableView: UITableView!
    var searchBar: UISearchBar!
        
    @IBOutlet weak var textLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = tv?.tvName
        setupNotification()
        setupChatRoomTableView()
        fetchMessages()
        
        
        // 検索バーアイテムの初期化
        searchBarButtonItem = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(searchBarButtonTapped(_:)))
        // ③検索バーボタンアイテムの追加
        self.navigationItem.rightBarButtonItems = [searchBarButtonItem]
        
        NotificationCenter.default.addObserver(self, selector: #selector(textFieldDidChange(notification:)),name: UITextView.textDidChangeNotification,
                                               object: chatInputAccessoryView.name)
        
    }
    
    // 文字数制限オブザーバの破棄
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    // 入力チェック(文字数チェック)処理
    @objc func textFieldDidChange(notification: NSNotification) {
        let textField = notification.object as! UITextView

        if let text = textField.text {
            if textField.markedTextRange == nil && text.count > maxLength {
                textField.text = text.prefix(maxLength).description
            }
        }
    }

    // 検索ボタンが押された時の処理
    @objc func searchBarButtonTapped(_ sender: UIBarButtonItem) {
        print("検索ボタンが押された!")
        setSearchBar()
    }
    
//検索バーの設置
    func setSearchBar() {
        // NavigationBarにSearchBarをセット
        if let navigationBarFrame = self.navigationController?.navigationBar.bounds {
            //NavigationBarに適したサイズの検索バーを設置
            let searchBar: UISearchBar = UISearchBar(frame: navigationBarFrame)
            //デリゲート
            searchBar.delegate = self
            //プレースホルダー
            searchBar.placeholder = "コメントを検索"
            //検索バーのスタイル
            searchBar.autocapitalizationType = UITextAutocapitalizationType.none
            //NavigationTitleが置かれる場所に検索バーを設置
            navigationItem.titleView = searchBar
            //NavigationTitleのサイズを検索バーと同じにする
            navigationItem.titleView?.frame = searchBar.frame
        }
        }
        
    //検索バーで入力する時
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        //キャンセルボタンを表示
        searchBar.setShowsCancelButton(true, animated: true)
        return true
    }
    
    //検索バーのキャンセルがタップされた時
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        //キャンセルボタンを非表示
        searchBar.showsCancelButton = false
        //キーボードを閉じる
        searchBar.resignFirstResponder()
        navigationItem.title = "";
        navigationItem.titleView = nil ;
        navigationItem.title = tv?.tvName
        searchText = ""
        messages.removeAll()
        fetchMessages()
        // テキストビューの処理が終わったあとに使ってるViewControllerで以下を発動し、message入力画面を再表示
        self.becomeFirstResponder()
    }
    
    //検索バーでEnterが押された時
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    //Labelに入力した値を設定
        searchBar.resignFirstResponder()
        searchText = searchBar.text!
        print("debug:searchbartext1", searchText)
        print("debug:messages", messages)
        messages.removeAll()
        searchMessages()
        self.chatRoomTableView.reloadData()
    }
    
    private func setupNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func setupChatRoomTableView() {
        chatRoomTableView.delegate = self
        chatRoomTableView.dataSource = self
        chatRoomTableView.register(UINib(nibName: "ChatRoomTableViewCell", bundle: nil), forCellReuseIdentifier: cellId)
        chatRoomTableView.backgroundColor = .rgb(red: 118, green: 140, blue: 180)
        chatRoomTableView.contentInset = tableViewContentInset
        chatRoomTableView.scrollIndicatorInsets = tableViewIndicatorInset
        chatRoomTableView.keyboardDismissMode = .interactive
        chatRoomTableView.transform = CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: 0)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        guard let userInfo = notification.userInfo else { return }
        
        print("debug:KeyboadShow", countKeybord)
        if countKeybord == 0 || countKeybord == 2 || countKeybord == 3{
            if let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as AnyObject).cgRectValue {
            
                if keyboardFrame.height <= accessoryHeight { return }
            
                let top = keyboardFrame.height - safeAreaBottom
                var moveY = -(top - chatRoomTableView.contentOffset.y)
                // 最下部以外の時は少しずれるので微調整
                if chatRoomTableView.contentOffset.y != -60 { moveY += 60 }
                let contentInset = UIEdgeInsets(top: top, left: 0, bottom: 0, right: 0)
            
                chatRoomTableView.contentInset = contentInset
                chatRoomTableView.scrollIndicatorInsets = contentInset
                print("debug:countKeyboardShow", countKeybord)
                print("debug:KeyboadShow2")
                chatRoomTableView.contentOffset = CGPoint(x: 0, y: moveY)
                
            }
            
            if  countKeybord == 3 {
                countKeybord = 2
            } else if countKeybord == 2 {
                countKeybord = 0
            } else {
                countKeybord = 1
            }
            
        }
        
    }
    
    @objc func keyboardWillHide() {
        print("debug:KeyboadHide")
        chatRoomTableView.contentInset = tableViewContentInset
        chatRoomTableView.scrollIndicatorInsets = tableViewIndicatorInset
        print("debug:countKeyboardHide", countKeybord)
        countKeybord = 2
    }
    
    override var inputAccessoryView: UIView? { chatInputAccessoryView }

    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    
    //メッセージの全件取得
    private func fetchMessages() {
        guard let tvDocId = tv?.documentId else { return }
        
    Firestore.firestore().collection("TVs").document(tvDocId).collection("messages").addSnapshotListener { (snapshots, err) in
            
            if let err = err {
                print("メッセージ情報の取得に失敗しました。\(err)")
                return
            }
            
        snapshots?.documentChanges.forEach({ (documentChange) in
            switch documentChange.type {
            case .added:
                let dic = documentChange.document.data()
                let message = Message(dic: dic)
//                message.tv = self.tv?.tv
                self.messages.append(message)
                self.messages.sort { (m1, m2) -> Bool in
                    let m1Date = m1.createdAt.dateValue()
                    let m2Date = m2.createdAt.dateValue()
                    return m1Date > m2Date
                }
                
                self.chatRoomTableView.reloadData()
//                self.chatRoomTableView.scrollToRow(at: IndexPath(row: self.messages.count - 1, section: 0), at: .bottom, animated: true)
                
            case .modified, .removed:
                print("nothing to do")
            }
        })
    }
    }
    
    //メッセージの検索取得
    private func searchMessages() {
        guard let tvDocId = tv?.documentId else { return }

        print("debug:searchText", searchText)
        
        Firestore.firestore().collection("TVs").document(tvDocId).collection("messages").order(by: "message").start(at: [searchText]).end(at: [searchText + "\u{f8ff}"]).addSnapshotListener { (snapshots, err) in
            
            if let err = err {
                print("メッセージ情報の取得に失敗しました。\(err)")
                return
            }
            
        snapshots?.documentChanges.forEach({ (documentChange) in
            switch documentChange.type {
            case .added:
                let dic = documentChange.document.data()
                let message = Message(dic: dic)
//                message.tv = self.tv?.tv
                self.messages.append(message)
                self.messages.sort { (m1, m2) -> Bool in
                    let m1Date = m1.createdAt.dateValue()
                    let m2Date = m2.createdAt.dateValue()
                    return m1Date > m2Date
                }
                
                self.chatRoomTableView.reloadData()
//                self.chatRoomTableView.scrollToRow(at: IndexPath(row: self.messages.count - 1, section: 0), at: .bottom, animated: true)
                
            case .modified, .removed:
                print("nothing to do")
            }
        })
    }
    }
    
    
}





    

extension ChatRoomViewController: ChatInputAccessoryViewDelegate {
    
    func tappedSendButton(text: String, name: String) {
        addMessageToFirestore(text: text, name: name)
        print("name, \(name)", text)
    }
    
    private func addMessageToFirestore(text: String, name: String) {
        guard let tvDocId = tv?.documentId else { return }
        print("tvDocId:, \(tvDocId)","id:, \(text)")
//        guard let id = tv?.id else { return }
        print("tvDocId:, \(tvDocId)","id:, \(text)")
        chatInputAccessoryView.removeText()
        let messageId = randomString(length: 20)
        
        let docData = [
            "name": name,
            "createdAt": Timestamp(),
            "id": 3,
            "message": text
            ] as [String : Any]
        Firestore.firestore().collection("TVs").document(tvDocId).collection("messages").document(messageId).setData(docData) { (err) in
            if let err = err {
                print("メッセージ情報の保存に失敗しました。\(err)")
                return
            }
            
            let latestMessageData = [
                "latestMessageId": messageId
            ]
            
            Firestore.firestore().collection("TVs").document(tvDocId).updateData(latestMessageData) { (err) in
                if let err = err {
                    print("最新メッセージの保存に失敗しました。\(err)")
                    return
                }
                
                print("メッセージの保存に成功しました。")
                
            }
        }
        
    }
    
    func randomString(length: Int) -> String {
        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let len = UInt32(letters.length)

        var randomString = ""
        for _ in 0 ..< length {
            let rand = arc4random_uniform(len)
            var nextChar = letters.character(at: Int(rand))
            randomString += NSString(characters: &nextChar, length: 1) as String
        }
        return randomString
    }
    
}

extension ChatRoomViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        chatRoomTableView.estimatedRowHeight = 20
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = chatRoomTableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! ChatRoomTableViewCell
        cell.transform = CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: 0)
//        cell.messageTextView.text = messages[indexPath.row]
        if messages.count != 0 {
            cell.message = messages[indexPath.row]
        }
        return cell
    }
    
}
