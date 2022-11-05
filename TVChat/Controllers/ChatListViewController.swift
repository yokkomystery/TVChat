//
//  ChatListViewController.swift
//  TVChat
//
//  Created by Satoshi Yokokawa on 2021/06/12.
//  Copyright © 2021 Satoshi Yokokawa. All rights reserved.
//

import UIKit
import Firebase
import Nuke


class ChatListViewController: UIViewController {
    
    private let cellId = "cellId"
    private var tvs = [Tv]()
    private var tvListener: ListenerRegistration?
    
    @IBOutlet weak var chatListTableView: UITableView!
    
    private var tv: Tv? {
        didSet {
            navigationItem.title = tv?.tvName
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        fetchTVInfoFromFirestore()
    }

    private func fetchTVInfoFromFirestore(){
        tvListener?.remove()
        
        chatListTableView.reloadData()
        print("reloadchatListorigin")
        tvListener = Firestore.firestore().collection("TVs")
            .addSnapshotListener { (snapshots, err) in
                print("reloadlist1")
                if let err = err {
                    print("ChatRooms情報の取得に失敗しました。\(err)")
                    return
                }
                
                snapshots?.documentChanges.forEach({ (documentChange) in
                    print("reloaddocumentChange.type", documentChange.type)
//                    self.tvs.removeAll()
//                    self.chatListTableView.reloadData()
//                    switch documentChange.type {
//                    case .added:
                        print("reloadlist3")
                        self.handleAddedDocumentChange(documentChange: documentChange)
                        print("reloadlist4")
//                    case .modified, .removed:
//                        print("nothing to do")
//                    }
                })
        }
    }
        
        
    private func handleAddedDocumentChange(documentChange: DocumentChange) {
        let dic = documentChange.document.data()
        let tv = Tv(dic: dic)
        tv.documentId = documentChange.document.documentID
        tvs.sort(by: { a, b -> Bool in
            return a.id < b.id
        })
        print("reloadchatListhandle")
        guard let tvId = tv.documentId else { return }
        let latestMessageId = tv.latestMessageId
        let intNum: Int = Int(tv.id) ?? 0
        tvs.forEach({ (tvid) in
            if tv.id == tvid.id{
                print("reloadtvid", tvid.id)
                tvs.remove(at: intNum - 1)
            }
        })

        print("reload,tvs",
              tvs)
            if latestMessageId == "" {
                self.tvs.append(tv)
                self.chatListTableView.reloadData()
                return
            }
                
            Firestore.firestore().collection("TVs").document(tvId).collection("messages").document(latestMessageId).getDocument { (messageSnapshot, err) in
                    
                    if let err = err {
                        print("最新情報の取得に失敗しました。\(err)")
                        return
                    }
                    
                    guard let dic = messageSnapshot?.data() else { return }
                    let message = Message(dic: dic)
                    tv.latestMessage = message
                    
                    self.tvs.append(tv)
                    
                    self.tvs.sort(by: { a, b -> Bool in
                        return a.id < b.id
                    })
                    print("reload,chatlist")
                    self.chatListTableView.reloadData()
                }
            }
        
    

  
    private func setupViews() {
        chatListTableView.tableFooterView = UIView()
        chatListTableView.delegate = self
        chatListTableView.dataSource = self
        navigationItem.title = "番組一覧"
        self.navigationController?.navigationBar.backgroundColor = UIColor.black
        self.navigationController?.navigationBar.tintColor = .white
        self.navigationController?.navigationBar.titleTextAttributes = [
            // 文字の色
            .foregroundColor: UIColor.white
        ]
    }
}




// MARK: - UITableViewDelegate, UITableViewDataSource
extension ChatListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tvs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = chatListTableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as!
            ChatListTableViewCell
        cell.tv = tvs[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("tapped table view")
        let storyboard = UIStoryboard.init(name: "ChatRoom", bundle: nil)
        let chatRoomViewController = storyboard.instantiateViewController(withIdentifier: "ChatRoomViewController") as! ChatRoomViewController
//        ChatRoomViewController.user = user
        chatRoomViewController.tv = tvs[indexPath.row]
        navigationController?.pushViewController(chatRoomViewController, animated: true)
    }
    
}

class ChatListTableViewCell: UITableViewCell {
    
    var tv: Tv? {
        didSet {
            guard let url = URL(string: tv?.image ?? "") else { return }
            Nuke.loadImage(with: url, into: userImageView)
            dateLabel.text = dateFormatterForDateLabel(date: tv?.latestMessage?.createdAt.dateValue() ?? Date())
            latestMessageLabel.text = tv?.latestMessage?.message
            
        }
    }
  

    @IBOutlet weak var latestMessageLabel: UILabel!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        userImageView.layer.cornerRadius = 35
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    private func dateFormatterForDateLabel(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: date)
    }
    
}

