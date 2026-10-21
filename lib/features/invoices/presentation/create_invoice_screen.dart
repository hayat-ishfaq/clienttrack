import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../app/theme/app_colors.dart';
import '../../../shared/widgets/buttons/primary_button.dart';
import '../../clients/data/client_repository.dart';
import '../../clients/domain/models/client_model.dart';
import '../data/invoice_repository.dart';
import '../domain/models/invoice_model.dart';
import '../domain/models/line_item_model.dart';

// Tax rate
const double _kTaxRate = 0.15;

// ---------------------------------------------------------------------------
// Screen 15: Create Invoice
// Conforms to visily-15-create-invoice.png
// ---------------------------------------------------------------------------

class CreateInvoiceScreen extends ConsumerStatefulWidget {
  const CreateInvoiceScreen({super.key});

  @override
  ConsumerState<CreateInvoiceScreen> createState() =>
      _CreateInvoiceScreenState();
}

class _CreateInvoiceScreenState extends ConsumerState<CreateInvoiceScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isGenerating = false;

  // ── State ──────────────────────────────────────────────────────────────────
  ClientModel? _selectedClient;
  DateTime _issueDate = DateTime.now();
  DateTime _dueDate = DateTime.now().add(const Duration(days: 14));
  final _invoiceNumberCtrl =
      TextEditingController(text: _generateInvoiceNumber());
  final _referenceCtrl = TextEditingController();

  final List<LineItemModel> _items = [
    const LineItemModel(
      id: 'item_1',
      description: 'Web Design Phase 1',
      category: 'Standard Service',
      amount: 1200,
    ),
    const LineItemModel(
      id: 'item_2',
      description: 'Logo Branding Package',
      category: 'Standard Service',
      amount: 850,
    ),
  ];

  // ── Computed ───────────────────────────────────────────────────────────────
  double get _subtotal => _items.fold(0, (s, i) => s + i.amount);
  double get _taxAmount => _subtotal * _kTaxRate;
  double get _total => _subtotal + _taxAmount;

  static String _generateInvoiceNumber() {
    final now = DateTime.now();
    final seq = (now.millisecondsSinceEpoch % 10000).toString().padLeft(4, '0');
    return 'INV-${now.year}-$seq';
  }

  @override
  void dispose() {
    _invoiceNumberCtrl.dispose();
    _referenceCtrl.dispose();
    super.dispose();
  }

  // ── Date pickers ───────────────────────────────────────────────────────────

  Future<void> _pickIssueDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _issueDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (ctx, child) => _datePickerTheme(ctx, child),
    );
    if (picked != null) setState(() => _issueDate = picked);
  }

  Future<void> _pickDueDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: _issueDate,
      lastDate: DateTime(2030),
      builder: (ctx, child) => _datePickerTheme(ctx, child),
    );
    if (picked != null) setState(() => _dueDate = picked);
  }

  Widget _datePickerTheme(BuildContext ctx, Widget? child) {
    return Theme(
      data: ThemeData.light().copyWith(
        colorScheme: const ColorScheme.light(
          primary: AppColors.primaryForest,
          onPrimary: Colors.white,
          surface: Colors.white,
        ),
        dialogTheme: const DialogThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
        ),
      ),
      child: child ?? const SizedBox(),
    );
  }

  // ── Client selector ────────────────────────────────────────────────────────

  void _showClientSelector() {
    final clients = ref.read(clientsStreamProvider).asData?.value ?? kSeedClients;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.55,
        maxChildSize: 0.85,
        builder: (_, controller) => Column(
          children: [
            // Handle
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Select Client',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),
            const Divider(height: 1, color: AppColors.border),
            Expanded(
              child: ListView.separated(
                controller: controller,
                itemCount: clients.length,
                separatorBuilder: (_, _) =>
                    const Divider(height: 1, color: AppColors.border),
                itemBuilder: (_, i) {
                  final c = clients[i];
                  final isSelected = c.id == _selectedClient?.id;
                  return ListTile(
                    leading: CircleAvatar(
                      radius: 20,
                      backgroundColor: AppColors.primaryForest
                          .withValues(alpha: 0.12),
                      child: Text(
                        c.name.isNotEmpty ? c.name.substring(0, 1).toUpperCase() : '?',
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryForest,
                        ),
                      ),
                    ),
                    title: Text(
                      c.name,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    subtitle: Text(
                      c.email,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(Icons.check_circle_rounded,
                            color: AppColors.primaryForest)
                        : null,
                    onTap: () {
                      setState(() => _selectedClient = c);
                      Navigator.pop(ctx);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Add line item ──────────────────────────────────────────────────────────

  void _addLineItem() {
    final descCtrl = TextEditingController();
    final catCtrl = TextEditingController(text: 'Standard Service');
    final amountCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const Text(
              'Add Line Item',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            _SheetField(
                controller: descCtrl,
                label: 'Description',
                hint: 'e.g. Web Design Phase 1'),
            const SizedBox(height: 12),
            _SheetField(
                controller: catCtrl,
                label: 'Category',
                hint: 'e.g. Standard Service'),
            const SizedBox(height: 12),
            _SheetField(
              controller: amountCtrl,
              label: 'Amount',
              hint: '0.00',
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              prefixText: '\$',
            ),
            const SizedBox(height: 20),
            PrimaryButton(
              label: 'Add Item',
              icon: Icons.add_rounded,
              onPressed: () {
                final amt = double.tryParse(amountCtrl.text) ?? 0;
                if (descCtrl.text.trim().isNotEmpty && amt > 0) {
                  setState(() {
                    _items.add(LineItemModel(
                      id: 'item_${DateTime.now().millisecondsSinceEpoch}',
                      description: descCtrl.text.trim(),
                      category: catCtrl.text.trim().isEmpty
                          ? 'Standard Service'
                          : catCtrl.text.trim(),
                      amount: amt,
                    ));
                  });
                  Navigator.pop(ctx);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _removeItem(int index) {
    HapticFeedback.lightImpact();
    setState(() => _items.removeAt(index));
  }

  // ── Generate Invoice ───────────────────────────────────────────────────────

  Future<void> _onGenerate() async {
    FocusScope.of(context).unfocus();
    if (_selectedClient == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        _snackBar('Please select a client first.', isError: true),
      );
      return;
    }
    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        _snackBar('Add at least one line item.', isError: true),
      );
      return;
    }

    setState(() => _isGenerating = true);
    try {
      final invoice = InvoiceModel(
        id: '',
        invoiceNumber: _invoiceNumberCtrl.text.trim().isNotEmpty
            ? _invoiceNumberCtrl.text.trim()
            : _generateInvoiceNumber(),
        clientId: _selectedClient!.id,
        clientName: _selectedClient!.name,
        clientEmail: _selectedClient!.email,
        clientPhone: _selectedClient!.phone,
        projectTitle: _referenceCtrl.text.trim().isNotEmpty
            ? _referenceCtrl.text.trim()
            : null,
        status: InvoiceStatus.draft,
        items: _items,
        subtotal: _subtotal,
        taxRate: _kTaxRate,
        taxAmount: _taxAmount,
        discountAmount: 0.0,
        totalAmount: _total,
        amountPaid: 0.0,
        issueDate: _issueDate,
        dueDate: _dueDate,
        notes: '',
        paymentTerms: 'Net 14',
      );

      await ref.read(invoiceRepositoryProvider).addInvoice(invoice);

      if (!mounted) return;
      setState(() => _isGenerating = false);

      HapticFeedback.lightImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        _snackBar('Invoice ${invoice.invoiceNumber} saved as draft.'),
      );
      context.pop();
    } catch (e) {
      if (!mounted) return;
      setState(() => _isGenerating = false);
      ScaffoldMessenger.of(context).showSnackBar(
        _snackBar('Failed to save invoice: $e', isError: true),
      );
    }
  }

  SnackBar _snackBar(String msg, {bool isError = false}) => SnackBar(
        content: Text(msg, style: const TextStyle(fontFamily: 'Inter')),
        backgroundColor:
            isError ? AppColors.overdueRed : AppColors.primaryForest,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      );

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat('MMM dd, yyyy');

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF9),
      appBar: _buildAppBar(),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            // ── Scrollable form ──────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── CLIENT INFORMATION ────────────────────────────────
                    _sectionLabel('CLIENT INFORMATION'),
                    const SizedBox(height: 10),
                    _buildClientSelector(),
                    const SizedBox(height: 24),

                    // ── Date row ──────────────────────────────────────────
                    Row(
                      children: [
                        Expanded(
                          child: _DateField(
                            label: 'Issue Date',
                            value: dateFmt.format(_issueDate),
                            onTap: _pickIssueDate,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _DateField(
                            label: 'Due Date',
                            value: dateFmt.format(_dueDate),
                            onTap: _pickDueDate,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // ── Invoice Number ────────────────────────────────────
                    _FieldLabel(
                      icon: Icons.description_outlined,
                      text: 'Invoice Number',
                    ),
                    const SizedBox(height: 8),
                    _StyledTextField(
                      controller: _invoiceNumberCtrl,
                      hint: 'INV-2024-0001',
                      keyboardType: TextInputType.text,
                    ),
                    const SizedBox(height: 16),

                    // ── Reference / Project ───────────────────────────────
                    _FieldLabel(
                      icon: Icons.add_circle_outline_rounded,
                      text: 'Reference / Project',
                    ),
                    const SizedBox(height: 8),
                    _StyledTextField(
                      controller: _referenceCtrl,
                      hint: 'e.g. Q2 Marketing Campaign',
                      keyboardType: TextInputType.text,
                    ),
                    const SizedBox(height: 28),

                    // ── SERVICES & ITEMS ──────────────────────────────────
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _sectionLabel('SERVICES & ITEMS'),
                        _AddItemButton(onTap: _addLineItem),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Line items
                    ..._items.asMap().entries.map((e) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _LineItemCard(
                            item: e.value,
                            onDelete: () => _removeItem(e.key),
                          ),
                        )),

                    if (_items.isEmpty)
                      _buildEmptyItems(),

                    const SizedBox(height: 16),

                    // ── Totals card ───────────────────────────────────────
                    _buildTotalsCard(),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),

            // ── Sticky bottom button ─────────────────────────────────────
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  // ── AppBar ─────────────────────────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded,
            size: 20, color: AppColors.textPrimary),
        onPressed: () => context.pop(),
      ),
      title: const Text(
        'New Invoice',
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
      centerTitle: true,
      actions: [
        // Draft badge
        Container(
          margin: const EdgeInsets.only(right: 16),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: AppColors.paidTealBg,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            'Draft',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryForest,
            ),
          ),
        ),
      ],
      bottom: const PreferredSize(
        preferredSize: Size.fromHeight(1),
        child: Divider(height: 1, color: AppColors.border),
      ),
    );
  }

  // ── Section label ──────────────────────────────────────────────────────────

  Widget _sectionLabel(String text) => Text(
        text,
        style: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
          color: AppColors.textSecondary,
          letterSpacing: 0.8,
        ),
      );

  // ── Client selector card ────────────────────────────────────────────────────

  Widget _buildClientSelector() {
    final client = _selectedClient;
    return GestureDetector(
      onTap: _showClientSelector,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(10),
              ),
              child: client != null
                  ? Center(
                      child: Text(
                        client.name.substring(0, 1),
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryForest,
                        ),
                      ),
                    )
                  : const Icon(Icons.person_outline_rounded,
                      color: AppColors.textSecondary, size: 22),
            ),
            const SizedBox(width: 12),
            // Name + email
            Expanded(
              child: client != null
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          client.name,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          client.email,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12.5,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    )
                  : const Text(
                      'Select a client...',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: AppColors.textSecondary, size: 20),
          ],
        ),
      ),
    );
  }

  // ── Empty items state ───────────────────────────────────────────────────────

  Widget _buildEmptyItems() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: const Column(
        children: [
          Icon(Icons.receipt_long_outlined,
              size: 32, color: AppColors.textSecondary),
          SizedBox(height: 8),
          Text(
            'No items yet',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Tap "+ Add Item" to add services or products.',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // ── Totals card ─────────────────────────────────────────────────────────────

  Widget _buildTotalsCard() {
    final fmt = NumberFormat('#,##0.##', 'en_US');
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2E5D31), Color(0xFF1B3E25)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2E5D31).withValues(alpha: 0.30),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Subtotal row
          _TotalRow(
            label: 'Subtotal',
            value: '\$${fmt.format(_subtotal)}',
            labelColor: const Color(0xFFB7D9BC),
            valueColor: Colors.white,
          ),
          const SizedBox(height: 6),
          // Tax row
          _TotalRow(
            label: 'Tax (${(_kTaxRate * 100).round()}%)',
            value: '\$${fmt.format(_taxAmount)}',
            labelColor: const Color(0xFFB7D9BC),
            valueColor: Colors.white,
          ),
          const SizedBox(height: 14),
          // Divider
          Container(height: 1, color: Colors.white.withValues(alpha: 0.15)),
          const SizedBox(height: 14),
          // TOTAL AMOUNT label
          const Text(
            'TOTAL AMOUNT',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFFB7D9BC),
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '\$${fmt.format(_total)}',
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }

  // ── Sticky bottom button ────────────────────────────────────────────────────

  Widget _buildBottomBar() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(
          20, 12, 20, 12 + MediaQuery.of(context).padding.bottom),
      child: PrimaryButton(
        label: 'Generate & Send Invoice',
        icon: Icons.send_rounded,
        isLoading: _isGenerating,
        onPressed: _onGenerate,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Date field
// ─────────────────────────────────────────────────────────────────────────────

class _DateField extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;

  const _DateField({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.calendar_today_outlined,
                size: 14, color: AppColors.primaryForest),
            const SizedBox(width: 5),
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border, width: 1),
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Field label with icon
// ─────────────────────────────────────────────────────────────────────────────

class _FieldLabel extends StatelessWidget {
  final IconData icon;
  final String text;

  const _FieldLabel({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 15, color: AppColors.primaryForest),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Styled text field
// ─────────────────────────────────────────────────────────────────────────────

class _StyledTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final TextInputType keyboardType;

  const _StyledTextField({
    required this.controller,
    required this.hint,
    required this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(
        fontFamily: 'Inter',
        fontSize: 14.5,
        color: AppColors.textPrimary,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 14,
          color: AppColors.textSecondary,
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: AppColors.primaryForest, width: 1.5),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Add Item pill button
// ─────────────────────────────────────────────────────────────────────────────

class _AddItemButton extends StatelessWidget {
  final VoidCallback onTap;
  const _AddItemButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: AppColors.primaryForest.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: AppColors.primaryForest.withValues(alpha: 0.25),
              width: 1),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add_rounded,
                size: 14, color: AppColors.primaryForest),
            SizedBox(width: 4),
            Text(
              'Add Item',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryForest,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Line Item Card
// ─────────────────────────────────────────────────────────────────────────────

class _LineItemCard extends StatelessWidget {
  final LineItemModel item;
  final VoidCallback onDelete;

  const _LineItemCard({required this.item, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat('#,##0.##', 'en_US');
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Description + category
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.description,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.category,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          // Amount
          Text(
            '\$${fmt.format(item.amount)}',
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: 12),
          // Delete icon
          GestureDetector(
            onTap: onDelete,
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: AppColors.overdueRedBg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.delete_outline_rounded,
                size: 16,
                color: AppColors.overdueRed,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Total row (inside dark card)
// ─────────────────────────────────────────────────────────────────────────────

class _TotalRow extends StatelessWidget {
  final String label;
  final String value;
  final Color labelColor;
  final Color valueColor;

  const _TotalRow({
    required this.label,
    required this.value,
    required this.labelColor,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 13,
            color: labelColor,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sheet form field (used in Add Line Item bottom sheet)
// ─────────────────────────────────────────────────────────────────────────────

class _SheetField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final TextInputType keyboardType;
  final String? prefixText;

  const _SheetField({
    required this.controller,
    required this.label,
    required this.hint,
    this.keyboardType = TextInputType.text,
    this.prefixText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 14.5,
            color: AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: hint,
            prefixText: prefixText,
            hintStyle: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
            filled: true,
            fillColor: const Color(0xFFF8FAF9),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border, width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: AppColors.primaryForest, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
