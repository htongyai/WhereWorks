import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final titleSize = size.width * 0.06;
    final sectionTitleSize = size.width * 0.045;
    final bodyTextSize = size.width * 0.035;
    final padding = size.width * 0.04;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Privacy Policy for WhereWorks',
              style: TextStyle(
                fontSize: titleSize,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: size.height * 0.01),
            Text(
              'Effective Date: April 16, 2025',
              style: TextStyle(
                fontSize: bodyTextSize * 0.8,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: size.height * 0.03),
            Text(
              'WhereWorks ("we," "our," or "us") is committed to protecting your privacy and ensuring that your personal data is handled responsibly and in accordance with applicable laws, including Thailand\'s Personal Data Protection Act (PDPA). This Privacy Policy is designed to inform you about our practices and your rights, and by using our services, you acknowledge and agree to the terms outlined herein.\n\nBy accessing or using the WhereWorks platform (the "Platform"), which includes our mobile apps and website, you expressly agree that WhereWorks is not responsible or liable for the handling, processing, or safeguarding of your data beyond what is required under applicable law. Use of the Platform constitutes your binding consent to the data practices described in this policy.',
              style: TextStyle(height: 1.5, fontSize: bodyTextSize),
            ),
            SizedBox(height: size.height * 0.03),
            Text(
              '1. Introduction',
              style: TextStyle(
                fontSize: sectionTitleSize,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: size.height * 0.02),
            Text(
              'This Privacy Policy explains how we collect, use, disclose, and safeguard your personal data when you engage with the Platform. It outlines what data we collect, why we collect it, how it is stored, and under what circumstances it may be shared or disclosed to third parties.\n\nBy using the Platform, you understand that WhereWorks has the right to process your personal data and, to the fullest extent permitted by law, disclaims all liability for any consequences arising from the use or misuse of such data. Your continued use of the Platform constitutes acceptance of this policy and an express waiver of any legal claims arising from our use of your data, except where prohibited by law.',
              style: TextStyle(height: 1.5, fontSize: bodyTextSize),
            ),
            SizedBox(height: size.height * 0.03),
            Text(
              '2. Information We Collect',
              style: TextStyle(
                fontSize: sectionTitleSize,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: size.height * 0.02),
            Text(
              'We may collect various types of personal data, including:\n\n• Identity Data: Full name, email address, and account credentials.\n• Contact Data: Phone number, billing address, and GPS-based location data.\n• Usage Data: Search history, engagement with listings, clicks, and page views.\n• Content Data: Reviews, images, and any content you voluntarily submit.\n• Technical Data: IP address, browser type, operating system, and device information.\n\nWe gather this data through forms, direct input, analytics tools, cookies, device sensors, and third-party integrations. By submitting this data or using the Platform, you grant WhereWorks permission to process and retain such data for business and operational purposes.',
              style: TextStyle(height: 1.5, fontSize: bodyTextSize),
            ),
            SizedBox(height: size.height * 0.03),
            Text(
              '3. How We Use Your Information',
              style: TextStyle(
                fontSize: sectionTitleSize,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: size.height * 0.02),
            Text(
              'Your personal data is used for purposes such as service delivery, improving our user experience, personalization of search results, communication, support, compliance with legal requirements, and internal research and development. The data enables us to provide features like mapping, filtering, and bookmarking locations.\n\nWe reserve the right to use your data for any purpose consistent with the reason it was collected, including for analytics, performance monitoring, security, and promotional activities. You agree that WhereWorks may use this data without additional consent unless local laws specifically require it.',
              style: TextStyle(height: 1.5, fontSize: bodyTextSize),
            ),
            SizedBox(height: size.height * 0.03),
            Text(
              '4. Sharing and Disclosure',
              style: TextStyle(
                fontSize: sectionTitleSize,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: size.height * 0.02),
            Text(
              'WhereWorks may disclose your personal data to third-party service providers, including those involved in web hosting, user analytics, communication systems, customer support tools, and marketing services. These entities are granted access solely for the purpose of fulfilling their designated functions.\n\nWe also reserve the right to share your data with legal authorities if compelled by law, court order, or legal process. Furthermore, if the company undergoes a merger, acquisition, or asset sale, your data may be transferred as part of the business transaction. You waive any objections to such disclosures to the extent permitted by law.',
              style: TextStyle(height: 1.5, fontSize: bodyTextSize),
            ),
            SizedBox(height: size.height * 0.03),
            Text(
              '5. International Data Transfers',
              style: TextStyle(
                fontSize: sectionTitleSize,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: size.height * 0.02),
            Text(
              'Your data may be stored or processed on servers located outside Thailand. These transfers may be necessary for technical infrastructure, redundancy, or use of cloud services. We implement reasonable safeguards to comply with PDPA requirements for international data transfers.\n\nBy using our Platform, you consent to such cross-border transfers and acknowledge that your personal data may be subject to foreign laws that may differ from those in your jurisdiction. WhereWorks will not be held liable for the acts or omissions of third-party data processors outside Thailand.',
              style: TextStyle(height: 1.5, fontSize: bodyTextSize),
            ),
            SizedBox(height: size.height * 0.03),
            Text(
              '6. Data Retention',
              style: TextStyle(
                fontSize: sectionTitleSize,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: size.height * 0.02),
            Text(
              'WhereWorks retains personal data only for as long as it is necessary to fulfill the purposes for which it was collected or to comply with applicable legal obligations. Once the data is no longer needed, it will be deleted, anonymized, or rendered inaccessible.\n\nWe reserve the right to retain anonymized or aggregated data indefinitely for purposes such as performance analysis, service improvement, and legal compliance. You acknowledge and agree that this retained data does not constitute personal data under applicable law once anonymized.',
              style: TextStyle(height: 1.5, fontSize: bodyTextSize),
            ),
            SizedBox(height: size.height * 0.03),
            Text(
              '7. Your Rights',
              style: TextStyle(
                fontSize: sectionTitleSize,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: size.height * 0.02),
            Text(
              'Under the PDPA, you may have rights related to your personal data, such as the right to request access, correction, deletion, or to object to processing. You also have the right to withdraw your consent where processing is based on consent.\n\nHowever, by creating an account and using the Platform, you acknowledge that in certain cases, WhereWorks may continue to process your data even after withdrawal of consent if allowed by law or required for legitimate business interests. All rights must be exercised in writing to support@whereworks.app.',
              style: TextStyle(height: 1.5, fontSize: bodyTextSize),
            ),
            SizedBox(height: size.height * 0.03),
            Text(
              '8. Data Security',
              style: TextStyle(
                fontSize: sectionTitleSize,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: size.height * 0.02),
            Text(
              'We take reasonable steps to protect your data using secure servers, encryption, and access controls. These technical and organizational measures are intended to prevent unauthorized access, misuse, loss, or alteration of your data.\n\nDespite our efforts, no system is fully secure. By using the Platform, you accept the risk of data breaches and agree that WhereWorks is not liable for any unauthorized access unless proven to be caused by gross negligence or intentional misconduct on our part.',
              style: TextStyle(height: 1.5, fontSize: bodyTextSize),
            ),
            SizedBox(height: size.height * 0.03),
            Text(
              '9. Children\'s Privacy',
              style: TextStyle(
                fontSize: sectionTitleSize,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: size.height * 0.02),
            Text(
              'The Platform is not intended for or directed to children under the age of 13. We do not knowingly collect or solicit personal data from children. Any user who provides personal information confirms they are 13 years or older.\n\nIf we learn that we have inadvertently collected personal data from a child under 13, we will delete such information as quickly as possible. Parents or guardians may contact us to request deletion of any child-related data.',
              style: TextStyle(height: 1.5, fontSize: bodyTextSize),
            ),
            SizedBox(height: size.height * 0.03),
            Text(
              '10. Changes to This Privacy Policy',
              style: TextStyle(
                fontSize: sectionTitleSize,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: size.height * 0.02),
            Text(
              'WhereWorks may modify this Privacy Policy from time to time. Updates will be posted on the Platform and noted with a revised "Effective Date." It is your responsibility to review the Privacy Policy periodically.\n\nYour continued use of the Platform after the updated Privacy Policy is posted constitutes your acceptance of the changes. If you disagree with the new terms, you should stop using the Platform immediately and delete your account if applicable.',
              style: TextStyle(height: 1.5, fontSize: bodyTextSize),
            ),
            SizedBox(height: size.height * 0.03),
            Text(
              '11. Contact Us',
              style: TextStyle(
                fontSize: sectionTitleSize,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: size.height * 0.02),
            Text(
              'If you have any questions, concerns, or requests regarding this Privacy Policy or your data rights, you can contact us via the following methods:\n\nEmail: support@whereworks.app\nAddress: [Insert Company Address, Bangkok, Thailand]\n\nWe will make reasonable efforts to respond to inquiries within 30 business days. For legal matters, please ensure that correspondence is clearly marked and addressed to our Data Protection Officer.\n\nBy creating an account or continuing to use the Platform, you affirm that you have read and understood this Privacy Policy. You also acknowledge and agree that WhereWorks assumes no liability for the processing or disclosure of your data beyond what is required under applicable Thai law, and you expressly waive any right to claim damages for data usage permitted by these terms.',
              style: TextStyle(height: 1.5, fontSize: bodyTextSize),
            ),
            SizedBox(height: size.height * 0.03),
          ],
        ),
      ),
    );
  }
} 