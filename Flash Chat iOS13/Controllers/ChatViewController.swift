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
    
    var messages: [Message] = [
        Message(sender: "teste@teste.com", body: "Hey"),
        Message(sender: "a@teste.com", body: "Hello!"),
        Message(sender: "teste@teste.com", body: "What's up? \n Are you ok? \n Whats going on?\n You are beautifull")
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //registro do dataSource para usar no extended do Protocolo UITableViewDataSource
        tableView.dataSource = self
        title = K.appName
        navigationItem.hidesBackButton = true
        
        // registrando o nib (arquivo XIB)
        tableView.register(UINib(nibName: K.cellNibName, bundle: nil), forCellReuseIdentifier: K.cellIdentifier)
        
    }
    
    @IBAction func sendPressed(_ sender: UIButton) {
        
        if let messageBody = messageTextfield.text,
           let messageSender = Auth.auth().currentUser?.email{ // Pega o email da pessoa logada
            db.collection(K.FStore.collectionName).addDocument(data: [K.FStore.senderField: messageSender,
                                                                      K.FStore.bodyField: messageBody]) { (error) in
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
