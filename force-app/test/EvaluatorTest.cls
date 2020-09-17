@isTest
private class EvaluatorTest {
    public class DataStoreMock implements DataStoreInterface {
        Map<String, DataModel.Flag> flags;
        Map<String, DataModel.Segment> segments;

        public DataStoreMock() {
            this.flags    = new Map<String, DataModel.Flag>();
            this.segments = new Map<String, DataModel.Segment>();
        }

        public DataModel.Flag getFlag(String key) {
            return this.flags.get(key);
        }

        public DataModel.Segment getSegment(String key) {
            return this.segments.get(key);
        }
    }

    @isTest static void offFlagReturnsOffVariation() {
        DataStoreMock store = new DataStoreMock();

        DataModel.Flag flag = new DataModel.Flag();
        flag.fieldOn = false;
        flag.variations.add(LDValue.of(true));

        Evaluator evaluator = new Evaluator(store);

        LDUser user = new LDUser.Builder('abc').build();

        Evaluator.EvalResult result = evaluator.evaluate(flag, user);

        System.assertEquals(result.getValue().booleanValue(), true);
        System.assertEquals(result.getVariationIndex(), 0);
        System.assertEquals(result.getReason().getKind(), EvaluationReason.Kind.OFF);
    }

    @isTest static void fallthroughEvaluationReturnsFallthrough() {
        DataStoreMock store = new DataStoreMock();

        DataModel.Flag flag = new DataModel.Flag();
        flag.fieldOn = true;
        flag.fallthrough.variation = 0;
        flag.variations.add(LDValue.of(true));

        Evaluator evaluator = new Evaluator(store);

        LDUser user = new LDUser.Builder('abc').build();

        Evaluator.EvalResult result = evaluator.evaluate(flag, user);

        System.assertEquals(result.getValue().booleanValue(), true);
        System.assertEquals(result.getVariationIndex(), 0);
        System.assertEquals(result.getReason().getKind(), EvaluationReason.Kind.FALLTHROUGH);
    }

    @isTest static void targetMatch() {
        DataStoreMock store = new DataStoreMock();

        DataModel.Flag flag = new DataModel.Flag();
        flag.fieldOn = true;
        flag.fallthrough.variation = 0;
        flag.variations.add(LDValue.of(true));

        DataModel.Target target = new DataModel.Target();
        target.values.add('abc');
        flag.targets.add(target);

        Evaluator evaluator = new Evaluator(store);

        LDUser user = new LDUser.Builder('abc').build();

        Evaluator.EvalResult result = evaluator.evaluate(flag, user);

        System.assertEquals(result.getValue().booleanValue(), true);
        System.assertEquals(result.getVariationIndex(), 0);
        System.assertEquals(result.getReason().getKind(), EvaluationReason.Kind.TARGET_MATCH);
    }

    @isTest static void targetNotMatch() {
        DataStoreMock store = new DataStoreMock();

        DataModel.Flag flag = new DataModel.Flag();
        flag.fieldOn = true;
        flag.fallthrough.variation = 0;
        flag.variations.add(LDValue.of(true));

        DataModel.Target target = new DataModel.Target();
        target.values.add('abc1');
        flag.targets.add(target);

        Evaluator evaluator = new Evaluator(store);

        LDUser user = new LDUser.Builder('abc').build();

        Evaluator.EvalResult result = evaluator.evaluate(flag, user);

        System.assertEquals(result.getValue().booleanValue(), true);
        System.assertEquals(result.getVariationIndex(), 0);
        System.assertEquals(result.getReason().getKind(), EvaluationReason.Kind.FALLTHROUGH);
    }

    @isTest static void prereqMatch() {
        DataStoreMock store = new DataStoreMock();

        DataModel.Flag flag = new DataModel.Flag();
        flag.fieldOn = true;
        flag.variations.add(LDValue.of(true));
        flag.fallthrough.variation = 0;

        flag.prerequisites.add(new DataModel.Prerequisite(0, 'other'));

        DataModel.Flag flagSub = new DataModel.Flag();
        flagSub.fieldOn = true;
        flagSub.fallthrough.variation = 0;
        flagSub.variations.add(LDValue.of(true));

        store.flags.put('other', flagSub);

        Evaluator evaluator = new Evaluator(store);

        LDUser user = new LDUser.Builder('abc').build();

        Evaluator.EvalResult result = evaluator.evaluate(flag, user);

        System.assertEquals(result.getValue().booleanValue(), true);
        System.assertEquals(result.getVariationIndex(), 0);
        System.assertEquals(result.getReason().getKind(), EvaluationReason.Kind.FALLTHROUGH);
    }

    @isTest static void prereqFailed() {
        DataStoreMock store = new DataStoreMock();

        DataModel.Flag flag = new DataModel.Flag();
        flag.fieldOn = true;
        flag.variations.add(LDValue.of(true));
        flag.fallthrough.variation = 0;

        flag.prerequisites.add(new DataModel.Prerequisite(0, 'other'));

        DataModel.Flag flagSub = new DataModel.Flag();
        flagSub.fieldOn = true;
        flagSub.fallthrough.variation = 1;
        flagSub.variations.add(LDValue.of(true));
        flagSub.variations.add(LDValue.of(false));

        store.flags.put('other', flagSub);

        Evaluator evaluator = new Evaluator(store);

        LDUser user = new LDUser.Builder('abc').build();

        Evaluator.EvalResult result = evaluator.evaluate(flag, user);

        System.assertEquals(result.getValue().booleanValue(), true);
        System.assertEquals(result.getVariationIndex(), 0);
        System.assertEquals(result.getReason().getKind(), EvaluationReason.Kind.PREREQUISITE_FAILED);
    }

    @isTest static void segmentIncludedUser() {
        DataStoreMock store = new DataStoreMock();

        DataModel.Clause clause = new DataModel.Clause('key', 'SEGMENT_MATCH');
        clause.values.add(LDValue.of('segment'));

        DataModel.Rule rule = new DataModel.Rule('rule');
        rule.clauses.add(clause);
        rule.vor.variation = 0;

        DataModel.Flag flag = new DataModel.Flag();
        flag.fieldOn = true;
        flag.variations.add(LDValue.of(true));
        flag.rules.add(rule);
        flag.fallthrough.variation = 0;

        DataModel.Segment segment = new DataModel.Segment('segment');
        segment.included.add('abc');

        store.segments.put('segment', segment);

        Evaluator evaluator = new Evaluator(store);

        LDUser user = new LDUser.Builder('abc').build();

        Evaluator.EvalResult result = evaluator.evaluate(flag, user);

        System.assertEquals(result.getValue().booleanValue(), true);
        System.assertEquals(result.getVariationIndex(), 0);
        System.assertEquals(result.getReason().getKind(), EvaluationReason.Kind.RULE_MATCH);
    }
}