// Task 2: Class অনুযায়ী মোট (Total) Transaction Amount বের করা
import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.io.DoubleWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Job;
import org.apache.hadoop.mapreduce.Mapper;
import org.apache.hadoop.mapreduce.Reducer;
import org.apache.hadoop.mapreduce.lib.input.FileInputFormat;
import org.apache.hadoop.mapreduce.lib.output.FileOutputFormat;

import java.io.IOException;

public class Task2_TotalAmountByClass {

    public static class SumMapper extends Mapper<Object, Text, Text, DoubleWritable> {

        private Text classKey = new Text();
        private DoubleWritable amount = new DoubleWritable();

        @Override
        protected void map(Object key, Text value, Context context)
                throws IOException, InterruptedException {

            String line = value.toString();
            if (line.startsWith("id,")) return;

            String[] fields = line.split(",");
            if (fields.length < 31) return;

            try {
                String cls = fields[30].trim();
                double amt = Double.parseDouble(fields[29]); // Amount column

                classKey.set(cls.equals("1") ? "Fraud" : "Legitimate");
                amount.set(amt);
                context.write(classKey, amount);
            } catch (NumberFormatException e) {
                // ভুল ডাটা স্কিপ
            }
        }
    }

    public static class SumReducer extends Reducer<Text, DoubleWritable, Text, DoubleWritable> {

        @Override
        protected void reduce(Text key, Iterable<DoubleWritable> values, Context context)
                throws IOException, InterruptedException {

            double sum = 0.0;
            for (DoubleWritable val : values) {
                sum += val.get();
            }
            context.write(key, new DoubleWritable(sum));
        }
    }

    public static void main(String[] args) throws Exception {
        if (args.length != 2) {
            System.err.println("Usage: Task2_TotalAmountByClass <input path> <output path>");
            System.exit(-1);
        }

        Configuration conf = new Configuration();
        Job job = Job.getInstance(conf, "Total Amount By Class");

        job.setJarByClass(Task2_TotalAmountByClass.class);
        job.setMapperClass(SumMapper.class);
        job.setCombinerClass(SumReducer.class);
        job.setReducerClass(SumReducer.class);

        job.setOutputKeyClass(Text.class);
        job.setOutputValueClass(DoubleWritable.class);

        FileInputFormat.addInputPath(job, new Path(args[0]));
        FileOutputFormat.setOutputPath(job, new Path(args[1]));

        System.exit(job.waitForCompletion(true) ? 0 : 1);
    }
}
