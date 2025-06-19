# GreenOps Maturity Assessment Worksheet

*A practical tool for evaluating and improving your cloud sustainability practices*

---

**CloudCostChefs GreenOps Series**  
Version 1.0 | June 2025

---

## Table of Contents

1. [Assessment Overview](#assessment-overview)
2. [Organization Information](#organization-information)
3. [Maturity Assessment Framework](#maturity-assessment-framework)
4. [Dimension 1: Visibility & Measurement](#dimension-1-visibility--measurement)
5. [Dimension 2: Optimization Practices](#dimension-2-optimization-practices)
6. [Dimension 3: Integration & Automation](#dimension-3-integration--automation)
7. [Dimension 4: Culture & Governance](#dimension-4-culture--governance)
8. [Dimension 5: Business Integration](#dimension-5-business-integration)
9. [Scoring Summary](#scoring-summary)
10. [Gap Analysis](#gap-analysis)
11. [Roadmap Planning](#roadmap-planning)
12. [Action Plan Template](#action-plan-template)

---

## Assessment Overview

### Purpose

This worksheet helps you systematically evaluate your organization's GreenOps maturity across five key dimensions. Use it to:

- **Assess Current State**: Understand where you are today
- **Identify Gaps**: Pinpoint areas for improvement
- **Set Targets**: Define realistic maturity goals
- **Plan Roadmap**: Create a time-bound improvement plan
- **Track Progress**: Measure advancement over time

### How to Use This Worksheet

1. **Gather Information**: Collect data about your current practices before starting
2. **Be Honest**: Accurate assessment is more valuable than high scores
3. **Involve Stakeholders**: Get input from multiple teams and perspectives
4. **Take Your Time**: Allow 45-60 minutes for a thorough assessment
5. **Document Evidence**: Note specific examples to support your ratings

### Assessment Team

**Primary Assessor:** _________________________________ **Date:** _____________

**Additional Participants:**
- ___________________________________ (Role: ___________________)
- ___________________________________ (Role: ___________________)
- ___________________________________ (Role: ___________________)
- ___________________________________ (Role: ___________________)

---

## Organization Information

### Basic Information

**Organization Name:** _________________________________________________

**Industry:** _________________________________________________________

**Organization Size:** 
- [ ] Small (1-100 employees)
- [ ] Medium (101-1000 employees)  
- [ ] Large (1001-5000 employees)
- [ ] Enterprise (5000+ employees)

**Cloud Environment:**
- [ ] Single Cloud Provider: ________________
- [ ] Multi-Cloud: _________________________
- [ ] Hybrid (Cloud + On-premises)

**Primary Cloud Providers:** (Check all that apply)
- [ ] Amazon Web Services (AWS)
- [ ] Microsoft Azure
- [ ] Google Cloud Platform (GCP)
- [ ] Oracle Cloud Infrastructure (OCI)
- [ ] Other: ______________________________

### Current State Context

**Monthly Cloud Spend:** $__________________

**Number of Development Teams:** ____________

**Number of Applications/Workloads:** _________

**Existing Practices:** (Check all that apply)
- [ ] FinOps program established
- [ ] DevOps practices implemented
- [ ] Sustainability/ESG initiatives
- [ ] Cost optimization efforts
- [ ] Cloud governance policies

**Assessment Motivation:** (Check primary reason)
- [ ] Starting GreenOps journey
- [ ] Improving existing practices
- [ ] Compliance requirements
- [ ] Cost optimization goals
- [ ] Sustainability commitments

---


## Maturity Assessment Framework

### Maturity Levels

**Level 1: Basic (Crawl)**
- Ad-hoc practices with minimal structure
- Manual processes and limited automation
- Individual or small team efforts
- Basic awareness and understanding

**Level 2: Developing (Walk)**
- Some structured processes and policies
- Basic automation and tool integration
- Team-level adoption and engagement
- Regular but basic measurement and reporting

**Level 3: Advanced (Run)**
- Comprehensive processes and governance
- Extensive automation and integration
- Organization-wide adoption and competency
- Advanced measurement and optimization

**Level 4: Leading (Fly)**
- Optimized and innovative practices
- Full automation and seamless integration
- Cultural embedding and strategic alignment
- Predictive and prescriptive capabilities

### Scoring Guidelines

For each dimension, evaluate your organization against the maturity indicators and select the level that best describes your current state:

- **Score 1**: Mostly Level 1 characteristics
- **Score 2**: Mostly Level 2 characteristics  
- **Score 3**: Mostly Level 3 characteristics
- **Score 4**: Mostly Level 4 characteristics
- **Score 1.5, 2.5, 3.5**: Between levels (use when you're transitioning)

### Evidence Collection

For each dimension, document specific examples that support your rating:

- **Current Practices**: What you're doing today
- **Tools and Processes**: Systems and workflows in place
- **Challenges**: Obstacles and limitations
- **Opportunities**: Areas for improvement

---

## Dimension 1: Visibility & Measurement

### Maturity Indicators

**Level 1: Basic (Crawl)**
- Carbon data collected manually or via basic tools
- Limited to high-level cloud provider dashboards
- No standardized measurement methodology
- Reporting is ad-hoc and manual

**Level 2: Developing (Walk)**
- Automated data collection from multiple sources
- Service-level emissions visibility
- Consistent methodology applied
- Regular reporting on basic metrics

**Level 3: Advanced (Run)**
- Real-time carbon dashboards with alerts
- Resource-level granularity for all services
- Standardized, documented methodology
- Trend analysis and forecasting

**Level 4: Leading (Fly)**
- Carbon data integrated with all infrastructure tools
- Workload-level and per-transaction visibility
- Activity-based measurement with high accuracy
- Predictive analytics and anomaly detection

### Assessment Questions

#### Data Collection
1. **How is carbon emissions data collected?**
   - [ ] Manual collection from cloud provider dashboards
   - [ ] Semi-automated with basic tools
   - [ ] Fully automated from multiple sources
   - [ ] Integrated with all infrastructure and monitoring tools

2. **What is the frequency of data collection?**
   - [ ] Monthly or less frequent
   - [ ] Weekly
   - [ ] Daily
   - [ ] Real-time

3. **What percentage of your cloud footprint is covered by carbon tracking?**
   - [ ] Less than 25%
   - [ ] 25-50%
   - [ ] 51-75%
   - [ ] More than 75%

#### Data Granularity
4. **At what level can you view carbon emissions?**
   - [ ] Account/subscription level only
   - [ ] Service level
   - [ ] Resource level
   - [ ] Workload/transaction level

5. **Can you break down emissions by team, application, or business unit?**
   - [ ] No breakdown capability
   - [ ] Basic breakdown by major categories
   - [ ] Detailed breakdown by teams/applications
   - [ ] Dynamic breakdown by any dimension

#### Methodology
6. **What carbon accounting methodology do you use?**
   - [ ] No consistent methodology
   - [ ] Basic spend-based estimation
   - [ ] Activity-based methodology
   - [ ] Hybrid approach with validation

7. **Is your methodology documented and consistently applied?**
   - [ ] No documentation
   - [ ] Basic documentation
   - [ ] Comprehensive documentation
   - [ ] Automated methodology with validation

#### Reporting
8. **What carbon metrics do you regularly report?**
   - [ ] No regular reporting
   - [ ] Basic emissions totals
   - [ ] Comprehensive metrics with trends
   - [ ] Advanced analytics with predictions

### Current State Assessment

**Overall Score for Dimension 1:** _____ / 4

**Supporting Evidence:**

**Current Practices:**
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________

**Tools and Processes:**
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________

**Challenges:**
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________

**Opportunities:**
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________

---

## Dimension 2: Optimization Practices

### Maturity Indicators

**Level 1: Basic (Crawl)**
- Manual optimizations when problems are obvious
- Focus on simple actions like deleting idle resources
- No structured process for implementing changes
- Limited to easy wins with immediate payback

**Level 2: Developing (Walk)**
- Regular optimization reviews (monthly/quarterly)
- Automated recommendations for common patterns
- Process for implementing and tracking changes
- Both quick wins and medium-term strategies

**Level 3: Advanced (Run)**
- Continuous optimization via automation
- Regular architecture reviews for efficiency
- Carbon considerations in new designs
- Advanced techniques like workload scheduling

**Level 4: Leading (Fly)**
- ML-driven optimization across cloud footprint
- Carbon efficiency as architectural principle
- Automated remediation of inefficiencies
- Continuous innovation in sustainable patterns

### Assessment Questions

#### Optimization Approach
1. **How are optimization opportunities identified?**
   - [ ] Manual identification when issues are obvious
   - [ ] Tool-assisted identification with basic recommendations
   - [ ] Systematic identification with advanced analytics
   - [ ] AI/ML-driven identification with predictive capabilities

2. **What process exists for implementing optimizations?**
   - [ ] No formal process
   - [ ] Basic process with manual tracking
   - [ ] Structured process with automated tracking
   - [ ] Fully automated process with continuous improvement

3. **How frequently are optimizations reviewed and implemented?**
   - [ ] Ad-hoc or when problems arise
   - [ ] Monthly or quarterly reviews
   - [ ] Weekly reviews with continuous implementation
   - [ ] Real-time optimization with automated implementation

#### Optimization Types
4. **What types of optimizations do you regularly implement?**
   - [ ] Basic cleanup (idle resources, old snapshots)
   - [ ] Rightsizing and scheduling optimizations
   - [ ] Advanced optimizations (workload placement, architecture)
   - [ ] Innovative optimizations (carbon-aware computing, ML-driven)

5. **Do you consider carbon impact in architectural decisions?**
   - [ ] No consideration of carbon impact
   - [ ] Occasional consideration for major decisions
   - [ ] Regular consideration with documented guidelines
   - [ ] Carbon impact is a primary architectural principle

#### Measurement & Tracking
6. **How do you track the impact of optimization initiatives?**
   - [ ] No systematic tracking
   - [ ] Basic tracking of cost savings
   - [ ] Comprehensive tracking of cost and carbon savings
   - [ ] Advanced tracking with business impact analysis

7. **Do you measure both financial and carbon savings?**
   - [ ] No measurement of savings
   - [ ] Financial savings only
   - [ ] Both financial and carbon savings
   - [ ] Comprehensive value measurement including non-financial benefits

### Current State Assessment

**Overall Score for Dimension 2:** _____ / 4

**Supporting Evidence:**

**Current Practices:**
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________

**Tools and Processes:**
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________

**Challenges:**
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________

**Opportunities:**
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________

---

## Dimension 3: Integration & Automation

### Maturity Indicators

**Level 1: Basic (Crawl)**
- Separate tools for carbon and cost tracking
- Manual data transfer between systems
- Limited or no automation
- No integration with CI/CD or infrastructure

**Level 2: Developing (Walk)**
- Basic integration between carbon and FinOps tools
- Some automated data collection and reporting
- Basic automation for common optimizations
- Simple checks in deployment pipelines

**Level 3: Advanced (Run)**
- Unified dashboards for carbon and cost
- Extensive automation for data and optimizations
- Integration with CI/CD for deployment validation
- Carbon checks in infrastructure as code

**Level 4: Leading (Fly)**
- Seamless integration across all platforms
- Full automation of measurement and optimization
- Carbon-aware CI/CD pipelines with enforcement
- Automated carbon budget management

### Assessment Questions

#### Tool Integration
1. **How well are your carbon tools integrated with other platforms?**
   - [ ] Completely separate tools and data
   - [ ] Basic integration with manual data sharing
   - [ ] Good integration with automated data sharing
   - [ ] Seamless integration across all platforms

2. **Is there integration between FinOps and GreenOps tools?**
   - [ ] No integration
   - [ ] Basic integration with shared dashboards
   - [ ] Comprehensive integration with unified workflows
   - [ ] Complete integration with shared governance

3. **Can teams access carbon data within their existing workflows?**
   - [ ] No access within existing workflows
   - [ ] Limited access through separate tools
   - [ ] Good access through integrated dashboards
   - [ ] Seamless access within all development tools

#### Automation Level
4. **What aspects of carbon tracking are automated?**
   - [ ] No automation
   - [ ] Basic data collection automation
   - [ ] Comprehensive tracking automation
   - [ ] Full automation with intelligent processing

5. **What aspects of optimization are automated?**
   - [ ] No automation
   - [ ] Basic cleanup automation
   - [ ] Advanced optimization automation
   - [ ] Intelligent, self-healing optimization

#### CI/CD Integration
6. **Is carbon impact assessed during development and deployment?**
   - [ ] No assessment during development/deployment
   - [ ] Manual assessment for major changes
   - [ ] Automated assessment with reporting
   - [ ] Automated assessment with enforcement

7. **Are there carbon checks or gates in your deployment pipelines?**
   - [ ] No carbon checks in pipelines
   - [ ] Basic checks with warnings
   - [ ] Comprehensive checks with gates
   - [ ] Intelligent checks with adaptive thresholds

### Current State Assessment

**Overall Score for Dimension 3:** _____ / 4

**Supporting Evidence:**

**Current Practices:**
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________

**Tools and Processes:**
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________

**Challenges:**
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________

**Opportunities:**
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________

---


## Dimension 4: Culture & Governance

### Maturity Indicators

**Level 1: Basic (Crawl)**
- Limited awareness of GreenOps principles
- Single person responsible for sustainability
- No formal policies or processes
- Minimal executive engagement

**Level 2: Developing (Walk)**
- GreenOps training for key teams
- Dedicated GreenOps team or function
- Basic policies and governance
- Executive reporting and sponsorship

**Level 3: Advanced (Run)**
- Organization-wide GreenOps competency
- Distributed responsibility model
- Comprehensive policy framework
- Executive KPIs tied to sustainability

**Level 4: Leading (Fly)**
- Sustainability embedded in company culture
- Cross-functional ownership and accountability
- Policy-as-code with automated enforcement
- Sustainability central to business strategy

### Assessment Questions

#### Awareness & Skills
1. **What percentage of technical staff understand GreenOps principles?**
   - [ ] Less than 25%
   - [ ] 25-50%
   - [ ] 51-75%
   - [ ] More than 75%

2. **Is there formal training on cloud sustainability practices?**
   - [ ] No formal training
   - [ ] Basic training for key personnel
   - [ ] Comprehensive training program
   - [ ] Continuous learning and certification program

3. **How is GreenOps knowledge shared across the organization?**
   - [ ] No systematic knowledge sharing
   - [ ] Informal sharing within teams
   - [ ] Formal knowledge sharing processes
   - [ ] Embedded in organizational learning culture

#### Roles & Responsibilities
4. **Who is responsible for GreenOps in your organization?**
   - [ ] No designated responsibility
   - [ ] Single individual as champion
   - [ ] Dedicated team or function
   - [ ] Distributed across multiple roles and teams

5. **Is responsibility centralized or distributed?**
   - [ ] No clear responsibility structure
   - [ ] Centralized with single point of accountability
   - [ ] Distributed with clear role definitions
   - [ ] Integrated into all relevant job functions

6. **Are GreenOps responsibilities included in job descriptions?**
   - [ ] No inclusion in job descriptions
   - [ ] Included for sustainability roles only
   - [ ] Included for relevant technical roles
   - [ ] Included across all applicable roles

#### Policies & Governance
7. **What formal GreenOps policies exist?**
   - [ ] No formal policies
   - [ ] Basic policies for major areas
   - [ ] Comprehensive policy framework
   - [ ] Dynamic, automated policy enforcement

8. **How are these policies enforced?**
   - [ ] No enforcement mechanism
   - [ ] Manual enforcement with reminders
   - [ ] Automated enforcement with exceptions
   - [ ] Intelligent enforcement with adaptive rules

9. **Is there executive oversight of GreenOps initiatives?**
   - [ ] No executive oversight
   - [ ] Occasional executive updates
   - [ ] Regular executive reviews and decisions
   - [ ] Executive KPIs tied to sustainability outcomes

#### Incentives & Recognition
10. **Are teams incentivized to improve carbon efficiency?**
    - [ ] No incentives for carbon efficiency
    - [ ] Informal recognition for improvements
    - [ ] Formal incentives and recognition programs
    - [ ] Carbon efficiency integrated into performance management

### Current State Assessment

**Overall Score for Dimension 4:** _____ / 4

**Supporting Evidence:**

**Current Practices:**
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________

**Tools and Processes:**
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________

**Challenges:**
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________

**Opportunities:**
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________

---

## Dimension 5: Business Integration

### Maturity Indicators

**Level 1: Basic (Crawl)**
- Carbon tracking seen as technical exercise
- No connection to business metrics
- Sustainability treated as cost center
- No value measurement for GreenOps initiatives

**Level 2: Developing (Walk)**
- Basic carbon budgets aligned to business units
- Carbon efficiency reported alongside costs
- ROI calculated for major initiatives
- Some connection to business objectives

**Level 3: Advanced (Run)**
- Carbon accounting integrated with finance
- Regular business reviews include sustainability
- Comprehensive ROI tracking for all initiatives
- Clear alignment to corporate ESG strategy

**Level 4: Leading (Fly)**
- Carbon treated as business currency
- Product decisions include carbon considerations
- Value quantification for all sustainability aspects
- Strategic advantage derived from GreenOps

### Assessment Questions

#### Business Alignment
1. **How is GreenOps aligned with business objectives?**
   - [ ] No alignment with business objectives
   - [ ] Basic alignment with sustainability goals
   - [ ] Strong alignment with business strategy
   - [ ] Integral to business strategy and competitive advantage

2. **Are carbon metrics included in business reviews?**
   - [ ] No inclusion in business reviews
   - [ ] Occasional inclusion in sustainability reports
   - [ ] Regular inclusion in business reviews
   - [ ] Central to business performance discussions

3. **Do product decisions include carbon considerations?**
   - [ ] No carbon considerations in product decisions
   - [ ] Occasional consideration for major decisions
   - [ ] Regular consideration with documented impact
   - [ ] Carbon impact central to product strategy

#### Value Measurement
4. **How do you measure the business value of GreenOps initiatives?**
   - [ ] No business value measurement
   - [ ] Basic cost savings calculation
   - [ ] Comprehensive ROI analysis
   - [ ] Multi-dimensional value quantification

5. **Is there a process for calculating ROI on sustainability investments?**
   - [ ] No ROI calculation process
   - [ ] Ad-hoc ROI calculation for major investments
   - [ ] Systematic ROI calculation for all investments
   - [ ] Advanced value modeling with predictive analytics

6. **Do you quantify non-financial benefits of carbon reduction?**
   - [ ] No quantification of non-financial benefits
   - [ ] Basic awareness of non-financial benefits
   - [ ] Systematic quantification of key benefits
   - [ ] Comprehensive value framework including all benefits

#### Budget & Resources
7. **Is there dedicated budget for GreenOps initiatives?**
   - [ ] No dedicated budget
   - [ ] Ad-hoc budget allocation
   - [ ] Dedicated annual budget
   - [ ] Integrated budget planning with business units

8. **How are carbon budgets allocated and managed?**
   - [ ] No carbon budget allocation
   - [ ] High-level carbon budget targets
   - [ ] Detailed carbon budgets by team/project
   - [ ] Dynamic carbon budget management

#### Strategic Impact
9. **Is cloud sustainability part of your corporate strategy?**
   - [ ] Not part of corporate strategy
   - [ ] Mentioned in sustainability initiatives
   - [ ] Integrated into corporate strategy
   - [ ] Central to competitive strategy

10. **Do you leverage GreenOps for competitive advantage?**
    - [ ] No competitive advantage consideration
    - [ ] Basic differentiation through sustainability
    - [ ] Clear competitive advantage from GreenOps
    - [ ] Market leadership through sustainable innovation

### Current State Assessment

**Overall Score for Dimension 5:** _____ / 4

**Supporting Evidence:**

**Current Practices:**
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________

**Tools and Processes:**
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________

**Challenges:**
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________

**Opportunities:**
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________

---

## Scoring Summary

### Individual Dimension Scores

| Dimension | Score | Level | Notes |
|-----------|-------|-------|-------|
| 1. Visibility & Measurement | _____ / 4 | _________ | _________________ |
| 2. Optimization Practices | _____ / 4 | _________ | _________________ |
| 3. Integration & Automation | _____ / 4 | _________ | _________________ |
| 4. Culture & Governance | _____ / 4 | _________ | _________________ |
| 5. Business Integration | _____ / 4 | _________ | _________________ |

### Overall Maturity Score

**Total Score:** _____ / 20

**Average Score:** _____ / 4

**Overall Maturity Level:**
- [ ] 1.0-1.5: Basic (Crawl)
- [ ] 1.6-2.5: Developing (Walk)
- [ ] 2.6-3.5: Advanced (Run)
- [ ] 3.6-4.0: Leading (Fly)

### Maturity Profile

**Strengths (Highest scoring dimensions):**
1. _________________________________________________________________
2. _________________________________________________________________
3. _________________________________________________________________

**Improvement Areas (Lowest scoring dimensions):**
1. _________________________________________________________________
2. _________________________________________________________________
3. _________________________________________________________________

### Assessment Summary

**Current State Description:**
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________

**Key Observations:**
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________

---

## Gap Analysis

### Target Maturity Setting

Based on your organizational context and goals, set target maturity levels for each dimension:

| Dimension | Current Score | Target Score | Gap | Priority |
|-----------|---------------|--------------|-----|----------|
| 1. Visibility & Measurement | _____ | _____ | _____ | ________ |
| 2. Optimization Practices | _____ | _____ | _____ | ________ |
| 3. Integration & Automation | _____ | _____ | _____ | ________ |
| 4. Culture & Governance | _____ | _____ | _____ | ________ |
| 5. Business Integration | _____ | _____ | _____ | ________ |

**Priority Levels:** High, Medium, Low

### Gap Analysis by Dimension

#### Dimension 1: Visibility & Measurement
**Current Level:** _____ **Target Level:** _____ **Gap:** _____

**Key Gaps:**
- _________________________________________________________________
- _________________________________________________________________
- _________________________________________________________________

**Required Capabilities:**
- _________________________________________________________________
- _________________________________________________________________
- _________________________________________________________________

#### Dimension 2: Optimization Practices
**Current Level:** _____ **Target Level:** _____ **Gap:** _____

**Key Gaps:**
- _________________________________________________________________
- _________________________________________________________________
- _________________________________________________________________

**Required Capabilities:**
- _________________________________________________________________
- _________________________________________________________________
- _________________________________________________________________

#### Dimension 3: Integration & Automation
**Current Level:** _____ **Target Level:** _____ **Gap:** _____

**Key Gaps:**
- _________________________________________________________________
- _________________________________________________________________
- _________________________________________________________________

**Required Capabilities:**
- _________________________________________________________________
- _________________________________________________________________
- _________________________________________________________________

#### Dimension 4: Culture & Governance
**Current Level:** _____ **Target Level:** _____ **Gap:** _____

**Key Gaps:**
- _________________________________________________________________
- _________________________________________________________________
- _________________________________________________________________

**Required Capabilities:**
- _________________________________________________________________
- _________________________________________________________________
- _________________________________________________________________

#### Dimension 5: Business Integration
**Current Level:** _____ **Target Level:** _____ **Gap:** _____

**Key Gaps:**
- _________________________________________________________________
- _________________________________________________________________
- _________________________________________________________________

**Required Capabilities:**
- _________________________________________________________________
- _________________________________________________________________
- _________________________________________________________________

---


## Roadmap Planning

### Implementation Timeline

**Target Completion Date:** _________________

**Assessment Date:** _____________________ **Reassessment Date:** _____________________

### Quarterly Roadmap

#### Q1 (______ to ______)

**Focus Areas:**
- _________________________________________________________________
- _________________________________________________________________

**Key Initiatives:**

| Initiative | Dimension | Owner | Success Criteria | Status |
|------------|-----------|-------|------------------|--------|
| __________ | _________ | _____ | ________________ | ______ |
| __________ | _________ | _____ | ________________ | ______ |
| __________ | _________ | _____ | ________________ | ______ |

**Resource Requirements:**
- Budget: $______________
- Personnel: _____________
- Tools/Training: ________

#### Q2 (______ to ______)

**Focus Areas:**
- _________________________________________________________________
- _________________________________________________________________

**Key Initiatives:**

| Initiative | Dimension | Owner | Success Criteria | Status |
|------------|-----------|-------|------------------|--------|
| __________ | _________ | _____ | ________________ | ______ |
| __________ | _________ | _____ | ________________ | ______ |
| __________ | _________ | _____ | ________________ | ______ |

**Resource Requirements:**
- Budget: $______________
- Personnel: _____________
- Tools/Training: ________

#### Q3 (______ to ______)

**Focus Areas:**
- _________________________________________________________________
- _________________________________________________________________

**Key Initiatives:**

| Initiative | Dimension | Owner | Success Criteria | Status |
|------------|-----------|-------|------------------|--------|
| __________ | _________ | _____ | ________________ | ______ |
| __________ | _________ | _____ | ________________ | ______ |
| __________ | _________ | _____ | ________________ | ______ |

**Resource Requirements:**
- Budget: $______________
- Personnel: _____________
- Tools/Training: ________

#### Q4 (______ to ______)

**Focus Areas:**
- _________________________________________________________________
- _________________________________________________________________

**Key Initiatives:**

| Initiative | Dimension | Owner | Success Criteria | Status |
|------------|-----------|-------|------------------|--------|
| __________ | _________ | _____ | ________________ | ______ |
| __________ | _________ | _____ | ________________ | ______ |
| __________ | _________ | _____ | ________________ | ______ |

**Resource Requirements:**
- Budget: $______________
- Personnel: _____________
- Tools/Training: ________

### Dependencies and Risks

#### Critical Dependencies
1. _________________________________________________________________
2. _________________________________________________________________
3. _________________________________________________________________

#### Key Risks and Mitigation Strategies
1. **Risk:** ____________________________________________________________
   **Mitigation:** ______________________________________________________

2. **Risk:** ____________________________________________________________
   **Mitigation:** ______________________________________________________

3. **Risk:** ____________________________________________________________
   **Mitigation:** ______________________________________________________

### Success Metrics

#### Quantitative Metrics
- **Carbon Efficiency Improvement:** ____% reduction in kg CO2e per $1000 spend
- **Cost Savings:** $_______ annual savings from optimization
- **Policy Compliance:** ____% of resources compliant with policies
- **Team Engagement:** ____% of teams actively participating

#### Qualitative Metrics
- **Executive Satisfaction:** ___________________________________________
- **Team Feedback:** ________________________________________________
- **Process Effectiveness:** __________________________________________
- **Cultural Change:** _______________________________________________

---

## Action Plan Template

### Immediate Actions (Next 30 Days)

#### Action 1
**Description:** _______________________________________________________
**Owner:** _____________ **Due Date:** _____________ **Priority:** _______
**Success Criteria:** ___________________________________________________
**Resources Needed:** __________________________________________________
**Status:** ___________________________________________________________

#### Action 2
**Description:** _______________________________________________________
**Owner:** _____________ **Due Date:** _____________ **Priority:** _______
**Success Criteria:** ___________________________________________________
**Resources Needed:** __________________________________________________
**Status:** ___________________________________________________________

#### Action 3
**Description:** _______________________________________________________
**Owner:** _____________ **Due Date:** _____________ **Priority:** _______
**Success Criteria:** ___________________________________________________
**Resources Needed:** __________________________________________________
**Status:** ___________________________________________________________

### Short-term Actions (Next 90 Days)

#### Action 1
**Description:** _______________________________________________________
**Owner:** _____________ **Due Date:** _____________ **Priority:** _______
**Success Criteria:** ___________________________________________________
**Resources Needed:** __________________________________________________
**Status:** ___________________________________________________________

#### Action 2
**Description:** _______________________________________________________
**Owner:** _____________ **Due Date:** _____________ **Priority:** _______
**Success Criteria:** ___________________________________________________
**Resources Needed:** __________________________________________________
**Status:** ___________________________________________________________

#### Action 3
**Description:** _______________________________________________________
**Owner:** _____________ **Due Date:** _____________ **Priority:** _______
**Success Criteria:** ___________________________________________________
**Resources Needed:** __________________________________________________
**Status:** ___________________________________________________________

### Medium-term Actions (Next 6 Months)

#### Action 1
**Description:** _______________________________________________________
**Owner:** _____________ **Due Date:** _____________ **Priority:** _______
**Success Criteria:** ___________________________________________________
**Resources Needed:** __________________________________________________
**Status:** ___________________________________________________________

#### Action 2
**Description:** _______________________________________________________
**Owner:** _____________ **Due Date:** _____________ **Priority:** _______
**Success Criteria:** ___________________________________________________
**Resources Needed:** __________________________________________________
**Status:** ___________________________________________________________

#### Action 3
**Description:** _______________________________________________________
**Owner:** _____________ **Due Date:** _____________ **Priority:** _______
**Success Criteria:** ___________________________________________________
**Resources Needed:** __________________________________________________
**Status:** ___________________________________________________________

### Communication Plan

#### Stakeholder Updates

**Executive Team:**
- **Frequency:** _______________________________________________________
- **Format:** __________________________________________________________
- **Key Messages:** ____________________________________________________

**Management Team:**
- **Frequency:** _______________________________________________________
- **Format:** __________________________________________________________
- **Key Messages:** ____________________________________________________

**Development Teams:**
- **Frequency:** _______________________________________________________
- **Format:** __________________________________________________________
- **Key Messages:** ____________________________________________________

**All Staff:**
- **Frequency:** _______________________________________________________
- **Format:** __________________________________________________________
- **Key Messages:** ____________________________________________________

### Progress Tracking

#### Monthly Check-ins

**Date:** _____________ **Attendees:** _________________________________

**Progress Summary:**
_________________________________________________________________
_________________________________________________________________

**Completed Actions:**
- _________________________________________________________________
- _________________________________________________________________
- _________________________________________________________________

**Challenges Encountered:**
- _________________________________________________________________
- _________________________________________________________________
- _________________________________________________________________

**Adjustments Needed:**
- _________________________________________________________________
- _________________________________________________________________
- _________________________________________________________________

**Next Month Focus:**
- _________________________________________________________________
- _________________________________________________________________
- _________________________________________________________________

### Assessment Review Schedule

#### Quarterly Reviews
- **Q1 Review Date:** _____________ **Completed:** [ ] Yes [ ] No
- **Q2 Review Date:** _____________ **Completed:** [ ] Yes [ ] No
- **Q3 Review Date:** _____________ **Completed:** [ ] Yes [ ] No
- **Q4 Review Date:** _____________ **Completed:** [ ] Yes [ ] No

#### Annual Reassessment
**Scheduled Date:** _____________ **Completed:** [ ] Yes [ ] No

**Maturity Progression:**
- **Starting Score:** _____ / 4
- **Current Score:** _____ / 4
- **Improvement:** _____ points

**Key Achievements:**
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________

**Lessons Learned:**
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________

**Next Year Priorities:**
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________

---

## Additional Resources

### CloudCostChefs GreenOps Resources

- **GreenOps Fundamentals Guide:** Learn the basics of cloud sustainability
- **GreenOps Governance Framework:** Implement organizational governance
- **GreenOps Implementation Guide:** Step-by-step implementation instructions
- **GreenOps Starter Kit:** Tools and templates for getting started

### External Resources

- **Green Software Foundation:** Industry standards and best practices
- **Cloud Provider Carbon Tools:** Native carbon tracking capabilities
- **Industry Benchmarks:** Compare your progress with industry standards
- **Training and Certification:** Build organizational capabilities

### Support and Community

- **CloudCostChefs Community:** Connect with other practitioners
- **Monthly Webinars:** Learn from experts and case studies
- **Implementation Support:** Get help with your GreenOps journey
- **Consulting Services:** Accelerate your maturity advancement

---

## Worksheet Completion

### Assessment Summary

**Assessment Completed By:** ___________________________________________

**Date Completed:** ___________________________________________________

**Overall Maturity Level:** ____________________________________________

**Top 3 Priorities:**
1. _________________________________________________________________
2. _________________________________________________________________
3. _________________________________________________________________

**Next Steps:**
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________

### Validation and Approval

**Reviewed By:** ______________________________________________________

**Approved By:** ______________________________________________________

**Date:** ____________________________________________________________

**Comments:**
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________

---

*This worksheet is part of the CloudCostChefs GreenOps series. For the latest updates and additional resources, visit cloudcostchefs.com/greenops*

**Document Version:** 1.0  
**Last Updated:** June 2025  
**Next Review:** December 2025
