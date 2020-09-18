//
//  ContentView.swift
//  CoreDataApp
//
//  Created by Kaio Guanais on 2020-09-03.
//

import SwiftUI
import CoreData

struct ContentView: View {
    var body: some View {
        NavigationView {
            Home()
                .navigationTitle("Core Data")
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct Home: View {
    @StateObject var model = dataModel()
    
    var body: some View {
        VStack {
            List {
                    ForEach(model.data, id: \.objectID) { obj in
                    // Extracting object
                    Text(model.getValue(obj: obj))
                        .onTapGesture { model.openUpdateView(obj: obj)}
                }
                    .onDelete(perform: model.deleteData(indexSet:))
            }
            .listStyle(InsetGroupedListStyle())

            HStack(spacing: 15) {
                TextField("Insert text", text: $model.txt)
                    .padding()
                Button(action: model.writeData) {
                    Text("Save")
                }
                .padding()
                .disabled(model.txt.isEmpty)
           }
    }
            .sheet(isPresented: $model.isUpdate) {
                updateView(model: model)
        }
}
    
struct updateView: View {
    @ObservedObject var model: dataModel
    
    var body: some View {
        VStack(spacing: 20) {
            TextField("Update here", text: $model.updateTxt)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            Button(action: model.updateData) {
                Text("Update")
            }
        }
        .padding()
    }
}

// MVVM Pattern
class dataModel: ObservableObject {
    @Published var data: [NSManagedObject] = []
    @Published var txt = ""
    @Published var isUpdate = false
    @Published var updateTxt = ""
    @Published var selectedObj = NSManagedObject()
    
    let context = persistentContainer.viewContext
    
    init() {
        readData()
    }
    
    func readData() {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Data")
        
        do {
            let results = try context.fetch(request)
            self.data = results as! [NSManagedObject]
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func writeData() {
        let entity = NSEntityDescription.insertNewObject(forEntityName: "Data", into: context)
        entity.setValue(txt, forKey: "value")
        txt = ""
        
        do {
            try context.save()
            self.data.append(entity)
            
        } catch  {
            print(error.localizedDescription)
        }
    }
    
    func deleteData(indexSet: IndexSet) {
        for index in indexSet {
            
            do {
                let obj = data[index]
                context.delete(obj)
                try context.save()
                
                let index = data.firstIndex(of: obj)
                data.remove(at: index!)
            } catch {
                print(error.localizedDescription)
            }

        }
    }
    
    func updateData() {
        let index = data.firstIndex(of: selectedObj)
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Data")
        
        do {
            let results = try context.fetch(request) as! [NSManagedObject]
           let obj =  results.first { obj -> Bool in
                if obj == selectedObj {return true}
                else {return false}
            }
            obj?.setValue(updateTxt, forKey: "value")
            try context.save()
            
            // if success, means update and close the view
            data[index!] = obj!
            isUpdate.toggle()
            updateTxt = ""
        }
        catch {
            print(error.localizedDescription)
        }
    }
    
    func getValue(obj: NSManagedObject) -> String {
        return obj.value(forKey: "value") as! String
    }
    
    func openUpdateView(obj: NSManagedObject) {
        selectedObj = obj
        isUpdate.toggle()
    }
}
    
}
