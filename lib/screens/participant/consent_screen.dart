import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/data_provider.dart';
import '../../models/models.dart';

class ConsentScreen extends StatefulWidget {
  final String participantId;
  final String studyId;

  const ConsentScreen({
    super.key,
    required this.participantId,
    required this.studyId,
  });

  @override
  State<ConsentScreen> createState() => _ConsentScreenState();
}

class _ConsentScreenState extends State<ConsentScreen> {
  bool _hasRead = false;
  final _scrollCtrl = ScrollController();
  bool _reachedBottom = false;

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(() {
      if (_scrollCtrl.position.pixels >=
          _scrollCtrl.position.maxScrollExtent - 100) {
        setState(() => _reachedBottom = true);
      }
    });
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final data = context.watch<DataProvider>();
    final study = data.getStudy(widget.studyId);
    final participant = data.getParticipant(widget.participantId);
    final sponsor = study != null ? data.getSponsor(study.sponsorId) : null;
    final fmt = DateFormat('MMMM d, yyyy');

    if (study == null || participant == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Informed Consent Form')),
        body: const Center(child: Text('Record not found.')),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Informed Consent Form'),
        centerTitle: false,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollCtrl,
              padding: const EdgeInsets.all(24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 720),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ICF Header
                      Card(
                        elevation: 1,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.assignment_outlined,
                                      color: Color(0xFF1565C0), size: 28),
                                  const SizedBox(width: 10),
                                  const Expanded(
                                    child: Text('INFORMED CONSENT FORM',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                            letterSpacing: 0.5,
                                            color: Color(0xFF1565C0))),
                                  ),
                                ],
                              ),
                              const Divider(height: 24),
                              Text(study.title,
                                  style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold)),
                              const SizedBox(height: 6),
                              Text(
                                  'Sponsor: ${sponsor?.name ?? 'Unknown'} · ${study.phase}',
                                  style: const TextStyle(
                                      color: Colors.grey, fontSize: 13)),
                              const SizedBox(height: 4),
                              Text(
                                  'Therapeutic Area: ${study.therapeuticArea} — ${study.indication}',
                                  style: const TextStyle(
                                      color: Colors.grey, fontSize: 13)),
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF5F5F5),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _MetaRow('Participant', participant.name),
                                    _MetaRow('Date', fmt.format(DateTime.now())),
                                    if (study.protocolDocumentName != null)
                                      _MetaRow('Protocol',
                                          study.protocolDocumentName!),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      _Section(
                        number: '1',
                        title: 'Purpose of the Study',
                        content:
                            'You are being asked to take part in a clinical research study. The purpose of this study is to evaluate ${study.description}\n\nParticipation in this study is completely voluntary. You may refuse to participate or withdraw at any time without penalty or loss of benefits to which you are otherwise entitled.',
                      ),

                      _Section(
                        number: '2',
                        title: 'Study Procedures',
                        content:
                            'If you agree to participate, you will be assigned to one of the study groups. You will be asked to:\n\n'
                            '• Attend scheduled clinic visits at ${data.getResearchCenter(participant.researchCenterId)?.name ?? "the research center"}\n'
                            '• Provide blood samples and undergo physical examinations at each visit\n'
                            '• Take the study medication (or placebo) as directed\n'
                            '• Complete questionnaires about your health and quality of life\n'
                            '• Report any side effects or health changes promptly\n'
                            '• Refrain from taking other investigational drugs during the study\n\n'
                            'The study will last approximately 52 weeks, with follow-up visits for up to 6 months after the last dose.',
                      ),

                      _Section(
                        number: '3',
                        title: 'Potential Risks and Discomforts',
                        content:
                            'As with any medical study, there are potential risks. Known and possible risks include:\n\n'
                            '• Common side effects: Fatigue, nausea, headache, and injection-site reactions (if applicable)\n'
                            '• Less common: Elevated liver enzymes, decreased white blood cell count\n'
                            '• Rare but serious: Allergic reactions, immune-related adverse events\n'
                            '• Risks of blood draws: Minor pain, bruising, or infection at needle site\n\n'
                            'The study team will monitor you closely and will address any concerns promptly. You will be informed of any new information that may affect your willingness to participate.',
                      ),

                      _Section(
                        number: '4',
                        title: 'Potential Benefits',
                        content:
                            'You may or may not benefit directly from participating in this study. The study drug may or may not help your condition.\n\n'
                            'However, your participation may benefit others in the future by helping researchers better understand ${study.indication} and potentially leading to new treatment options.\n\n'
                            'All study-related visits, procedures, and the investigational drug will be provided at no cost to you.',
                      ),

                      _Section(
                        number: '5',
                        title: 'Confidentiality',
                        content:
                            'All information collected about you in this study will be kept strictly confidential to the extent permitted by law.\n\n'
                            '• Your study records will be identified by a participant code, not your name\n'
                            '• Only authorized study personnel will have access to identifiable information\n'
                            '• ${sponsor?.name ?? "The sponsor"} may review your study records for monitoring and audit purposes, but your identity will remain confidential\n'
                            '• Results of this study may be published in scientific journals, but your identity will not be revealed',
                      ),

                      _Section(
                        number: '6',
                        title: 'Voluntary Participation and Right to Withdraw',
                        content:
                            'Your participation in this study is entirely voluntary.\n\n'
                            '• You may choose not to participate without any penalty\n'
                            '• You may withdraw from the study at any time, for any reason, without penalty or loss of benefits\n'
                            '• Your decision will not affect your regular medical care\n'
                            '• If you withdraw, the information already collected may still be used in the study analysis\n\n'
                            'If new information becomes available that may affect your willingness to continue, we will promptly inform you.',
                      ),

                      _Section(
                        number: '7',
                        title: 'Contact Information',
                        content:
                            'If you have any questions about this study or your rights as a research participant, please contact:\n\n'
                            '• Study Coordinator at ${data.getResearchCenter(participant.researchCenterId)?.contactEmail ?? "your research center"}\n'
                            '• Sponsor Medical Affairs: ${sponsor?.contactEmail ?? "the study sponsor"}\n'
                            '• Independent Ethics Committee / IRB: ethics@consentiq.com\n\n'
                            'For medical emergencies related to the study, contact the 24-hour emergency line: +1 (800) CONSENT',
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Consent action bar
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, -2)),
              ],
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!_reachedBottom)
                      const Padding(
                        padding: EdgeInsets.only(bottom: 10),
                        child: Row(
                          children: [
                            Icon(Icons.keyboard_arrow_down,
                                color: Color(0xFFF57C00), size: 16),
                            SizedBox(width: 4),
                            Text(
                                'Please scroll to the bottom to read the full consent form.',
                                style: TextStyle(
                                    color: Color(0xFFF57C00), fontSize: 12)),
                          ],
                        ),
                      ),
                    InkWell(
                      onTap: _reachedBottom
                          ? () => setState(() => _hasRead = !_hasRead)
                          : null,
                      borderRadius: BorderRadius.circular(8),
                      child: Row(
                        children: [
                          Checkbox(
                            value: _hasRead,
                            onChanged: _reachedBottom
                                ? (v) => setState(() => _hasRead = v ?? false)
                                : null,
                            activeColor: const Color(0xFF1565C0),
                          ),
                          const Expanded(
                            child: Text(
                              'I confirm that I have read, understood, and had the opportunity to ask questions about this Informed Consent Form.',
                              style: TextStyle(fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _hasRead
                                ? () async {
                                    final ok = await showDialog<bool>(
                                      context: context,
                                      builder: (_) => AlertDialog(
                                        title:
                                            const Text('Confirm Decline'),
                                        content: const Text(
                                            'Are you sure you do not wish to participate in this study? You can reconsider at any time by contacting your research center.'),
                                        actions: [
                                          TextButton(
                                              onPressed: () => Navigator.of(
                                                      context)
                                                  .pop(false),
                                              child: const Text('Cancel')),
                                          OutlinedButton(
                                            onPressed: () =>
                                                Navigator.of(context)
                                                    .pop(true),
                                            style: OutlinedButton.styleFrom(
                                                foregroundColor:
                                                    Colors.red),
                                            child: const Text('Decline'),
                                          ),
                                        ],
                                      ),
                                    );
                                    if (ok == true && context.mounted) {
                                      context
                                          .read<DataProvider>()
                                          .submitConsent(widget.participantId,
                                              consented: false);
                                      Navigator.of(context).pop();
                                    }
                                  }
                                : null,
                            style: OutlinedButton.styleFrom(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 14),
                              foregroundColor: Colors.red,
                            ),
                            child: const Text('Decline Participation'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 2,
                          child: FilledButton.icon(
                            onPressed: _hasRead
                                ? () async {
                                    final ok = await showDialog<bool>(
                                      context: context,
                                      builder: (_) => AlertDialog(
                                        icon: const Icon(
                                            Icons.check_circle,
                                            color: Color(0xFF2E7D32),
                                            size: 40),
                                        title: const Text(
                                            'Confirm Your Consent'),
                                        content: const Text(
                                            'By clicking "I Agree", you confirm that you have read and understood the Informed Consent Form, had all your questions answered, and voluntarily agree to participate in this clinical study.'),
                                        actions: [
                                          TextButton(
                                              onPressed: () =>
                                                  Navigator.of(context)
                                                      .pop(false),
                                              child: const Text('Review Again')),
                                          FilledButton(
                                            onPressed: () =>
                                                Navigator.of(context)
                                                    .pop(true),
                                            style: FilledButton.styleFrom(
                                                backgroundColor:
                                                    const Color(0xFF2E7D32)),
                                            child: const Text('I Agree'),
                                          ),
                                        ],
                                      ),
                                    );
                                    if (ok == true && context.mounted) {
                                      context
                                          .read<DataProvider>()
                                          .submitConsent(widget.participantId,
                                              consented: true);
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(const SnackBar(
                                        content: Text(
                                            'Your consent has been recorded. Thank you for participating.'),
                                        backgroundColor:
                                            Color(0xFF2E7D32),
                                        duration: Duration(seconds: 4),
                                      ));
                                      Navigator.of(context).pop();
                                    }
                                  }
                                : null,
                            icon: const Icon(Icons.verified),
                            label: const Text('I Agree to Participate',
                                style: TextStyle(fontSize: 15)),
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFF2E7D32),
                              padding:
                                  const EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String number;
  final String title;
  final String content;

  const _Section(
      {required this.number, required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Card(
        elevation: 1,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 12,
                    backgroundColor:
                        const Color(0xFF1565C0).withOpacity(0.1),
                    child: Text(number,
                        style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1565C0))),
                  ),
                  const SizedBox(width: 10),
                  Text(title,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15)),
                ],
              ),
              const SizedBox(height: 12),
              Text(content,
                  style: const TextStyle(fontSize: 14, height: 1.6,
                      color: Color(0xFF37474F))),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  final String label;
  final String value;
  const _MetaRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(label,
                style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500)),
          ),
          Text(value, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}
