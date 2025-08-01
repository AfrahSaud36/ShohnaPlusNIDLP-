import SwiftUI
import PhotosUI

struct NewAddView: View {
    @EnvironmentObject var returnDataModel: ReturnDataModel
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var vm = NewAddReturnViewModel()

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("معلومات الشحنة").foregroundColor(AppColors.primaryColor)) {
                    TextField("رقم الطلب", text: $vm.orderNumber)
                    DatePicker("تاريخ الإرجاع", selection: $vm.returnDate, displayedComponents: .date)
                    TextField("معلومات الشحن", text: $vm.shippingInfo)
                }
                Section(header: Text("تفاصيل الشحنة").foregroundColor(AppColors.primaryColor)) {
                    TextField("مكان الإرسال (المنشأ)", text: $vm.origin)
                    TextField("مكان الاستلام (الوجهة)", text: $vm.destination)
                    TextField("الوزن", text: $vm.weight)
                        .keyboardType(.decimalPad)
                    DatePicker("تاريخ الطلب", selection: $vm.orderDate, displayedComponents: .date)
                }
                Section(header: Text("المرفقات (صور المنتج)").foregroundColor(AppColors.primaryColor)) {
                    PhotosPicker(selection: $vm.selectedItems, maxSelectionCount: vm.imageLimit, matching: .images) {
                        Label("اختيار صور المنتج", systemImage: "photo.on.rectangle.angled")
                    }
                    if !vm.selectedImages.isEmpty {
                        ScrollView(.horizontal) {
                            HStack {
                                ForEach(0..<vm.selectedImages.count, id: \.self) { index in
                                    vm.selectedImages[index]
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: 100)
                                        .cornerRadius(5)
                                }
                            }
                        }
                        .padding(.top, 8)
                    } else {
                        Text("لا توجد صور مختارة")
                            .foregroundColor(.gray)
                    }
                }
                .onChange(of: vm.selectedItems) { _ in
                    vm.handleSelectedItemsChange()
                }
                Section {
                    Button(action: {
                        let newReturn = vm.createReturnInformation()
                        returnDataModel.returnItems.append(newReturn)
                        let newItemId = newReturn.id
                        Task {
                            await returnDataModel.analyzeReturnImages(for: newItemId)
                        }
                        presentationMode.wrappedValue.dismiss()
                        vm.reset()
                    }) {
                        HStack {
                            Spacer()
                            Text("إرسال طلب جديد")
                                .font(.headline)
                                .foregroundColor(.white)
                            Spacer()
                        }
                        .padding()
                        .background(AppColors.primaryColor)
                        .cornerRadius(10)
                    }
                    .listRowInsets(EdgeInsets())
                    .buttonStyle(.plain)
                }
            }
            .navigationTitle("إضافة طلب جديد")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(AppColors.primaryColor, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
        .environment(\.layoutDirection, .rightToLeft)
    }
}

struct NewAddView_Previews: PreviewProvider {
    static var previews: some View {
        NewAddView()
            .environmentObject(ReturnDataModel())
    }
} 
