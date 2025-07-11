import 'package:flutter/material.dart';
import '../services/company_service.dart';

class WWScreen extends StatefulWidget {
  const WWScreen({super.key});

  @override
  State<WWScreen> createState() => _WWScreenState();
}

class _WWScreenState extends State<WWScreen> {
  List<Map<String, dynamic>> myCompanies = [];

  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _typeController = TextEditingController();
  final _addressController = TextEditingController();

  Map<String, dynamic>? editingCompany;

  @override
  void initState() {
    super.initState();
    _loadMyCompanies();
  }

  void _loadMyCompanies() async {
    try {
      final data = await CompanyService.getMyCompanies();
      setState(() {
        myCompanies = data;
      });
    } catch (e) {
      _showError('Lỗi tải công ty: $e');
    }
  }

  void _showCompanyDialog({Map<String, dynamic>? company}) {
    editingCompany = company;
    if (company != null) {
      _nameController.text = company['name'] ?? '';
      _descController.text = company['descriptionCompany'] ?? '';
      _typeController.text = company['type'] ?? '';
      _addressController.text = company['address'] ?? '';
    } else {
      _nameController.clear();
      _descController.clear();
      _typeController.clear();
      _addressController.clear();
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(company != null ? 'Cập nhật công ty' : 'Tạo công ty mới'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              _buildTextField(_nameController, 'Tên công ty'),
              _buildTextField(_descController, 'Mô tả'),
              _buildTextField(_typeController, 'Loại hình'),
              _buildTextField(_addressController, 'Địa chỉ'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFB84DF1)),
            onPressed: () {
              company != null
                  ? _updateCompany(company['id'] as int)
                  : _createCompany();
              Navigator.pop(context);
            },
            child: const Text('Xác nhận'),
          ),
        ],
      ),
    );
  }

  void _createCompany() async {
    try {
      final result = await CompanyService.createCompany(
        name: _nameController.text,
        descriptionCompany: _descController.text,
        type: _typeController.text,
        address: _addressController.text,
      );
      setState(() => myCompanies.add(result));
    } catch (e) {
      _showError('Tạo công ty thất bại: $e');
    }
  }

  void _updateCompany(int id) async {
    try {
      final result = await CompanyService.updateCompany(
        id: id,
        name: _nameController.text,
        descriptionCompany: _descController.text,
        type: _typeController.text,
        address: _addressController.text,
      );
      setState(() {
        final index = myCompanies.indexWhere((c) => c['id'] == result['id']);
        if (index != -1) {
          myCompanies[index] = result;
        }
      });
    } catch (e) {
      _showError('Cập nhật thất bại: $e');
    }
  }

  void _deleteCompany(int id) async {
    try {
      await CompanyService.deleteCompany(id);
      setState(() {
        myCompanies.removeWhere((c) => c['id'] == id);
      });
    } catch (e) {
      _showError('Xóa thất bại: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Widget _buildTextField(TextEditingController controller, String hint) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(hintText: hint, border: const OutlineInputBorder()),
      ),
    );
  }

  Widget _buildGradientButton() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: const LinearGradient(colors: [Color(0xFFB84DF1), Color(0xFF4ED0EB)]),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _showCompanyDialog(),
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 14, horizontal: 20),
            child: Row(
              children: [
                Icon(Icons.add_business, color: Colors.white),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Tạo công ty mới',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompanyCard(Map<String, dynamic> company) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEDE7F6),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(2, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(company['name'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text('Mô tả: ${company['descriptionCompany']}'),
          Text('Loại hình: ${company['type']}'),
          Text('Địa chỉ: ${company['address']}'),
          const SizedBox(height: 10),
          Row(
            children: [
              ElevatedButton(
                onPressed: () => _showCompanyDialog(company: company),
                child: const Text('Sửa'),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: () => _deleteCompany(company['id'] as int),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Xóa'),
              ),
            ],
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [Color(0xFFB84DF1), Color(0xFF4ED0EB)]),
          ),
          child: AppBar(
            title: const Text('Quản lý công ty'),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildGradientButton(),
            for (var company in myCompanies) _buildCompanyCard(company),
          ],
        ),
      ),
    );
  }
}
