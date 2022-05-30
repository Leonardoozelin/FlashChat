//
//  ChatViewController.swift
//  Flash Chat iOS13
//
//  Created by Angela Yu on 21/10/2019.
//  Copyright © 2019 Angela Yu. All rights reserved.
//

import UIKit
import Firebase

class ChatViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageTextfield: UITextField!
    
    let db = Firestore.firestore()
    
    var messages: [Message] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //registro do dataSource para usar no extended do Protocolo UITableViewDataSource
        tableView.dataSource = self
        title = K.appName
        navigationItem.hidesBackButton = true
        
        // registrando o nib (arquivo XIB)
        tableView.register(UINib(nibName: K.cellNibName, bundle: nil), forCellReuseIdentifier: K.cellIdentifier)
        
        loadMessages()
        
    }
    
    final func loadMessages(){
        db.collection(K.FStore.collectionName)
            .order(by: K.FStore.dateField) // OrderBy do Firestore
            .addSnapshotListener { (querySnapshot, error) in // .addSnapShotListener deixa serve para deixar em real time a consulta no banco de dados
                self.messages = []
                if let e = error {
                    print("There was an inssue retrieving data from Firestrore. \(e)")
                } else {
                    if let snapshotDocuments = querySnapshot?.documents {
                        for doc in snapshotDocuments {
                            let data = doc.data()
                            if let messageSender = data[K.FStore.senderField] as? String, let messageBody = data[K.FStore.bodyField] as? String {
                                let newMessage = Message(sender: messageSender, body: messageBody)
                                self.messages.append(newMessage)
                                
                                DispatchQueue.main.async { //deixa a consulta asyncrona e so ira chamar a funcao de reload apos terminar a consulta
                                    self.tableView.reloadData()
                                }
                            }
                        }
                    }
                }
            }
    }
    
    @IBAction func sendPressed(_ sender: UIButton) {
        
        if let messageBody = messageTextfield.text,
           let messageSender = Auth.auth().currentUser?.email{ // Pega o email da pessoa logada
            db.collection(K.FStore.collectionName)
                .addDocument(data: [K.FStore.senderField: messageSender,
                                    K.FStore.bodyField: messageBody,
                                    K.FStore.dateField: Date().timeIntervalSince1970]) { (error) in
                    if let e = error{
                        print("There was an issue saving data to firestore, \(e)")
                    }    else {
                        print("Successfully saved data")
                    }
                } // Salvando as mensagens no Firestore do Firabase.
        }
    }
    
    @IBAction func logOutPressed(_ sender: UIBarButtonItem) {
        do {
            try Auth.auth().signOut()
            navigationController?.popToRootViewController(animated: true)
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
        
    }
    
}

extension ChatViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.cellIdentifier, for: indexPath) as! MessageCell
        cell.label.text = messages[indexPath.row].body
        return cell
    }
}
